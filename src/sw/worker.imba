const imbac = require 'imba/compiler'
global.imbac = imbac

#  TODO - do the same live import for imdb and future libraryes
const ResolveMap = {
	'imba': import('../imba.imba?as=web,module').url
	'imdb': '/imdb.js'
}

const mimeTypeMap = {
	'html': 'text/html;charset=utf-8'
	'css': 'text/css;charset=utf-8'
	'js': 'application/javascript;charset=utf-8'
	'imba': 'application/javascript;charset=utf-8'
	'png': 'image/png'
	'jpg': 'image/jpg'
	'jpeg': 'image/jpg'
	'gif': 'image/gif'
	'svg': 'image/svg+xml'
}

const indexTemplate = "
<html>
    <head>
        <meta charset='UTF-8'>
		<title>Playground</title>
		<link href='/preflight.css' rel='stylesheet'>
    </head>
    <body>
		<script type='module' src='/repl/examples/helpers.imba'></script>
        <script type='module' src='./index.imba'></script>
    </body>
</html>"

const clientServiceMap = {}
const clientIdMap = {}
const services = {}
const nr = Math.random!
global.services = services

console.log "starting worker!!!!",self

def compileImba file
	try
		let body = file.body
		# rewrite certain special things
		body = body.replace(/# @(show|log)( .*)?\n(\t*)/g) do(m,typ,text,tabs)
			m + "${typ} '{(text or '').trim!}', "
		body = body.replace(/from 'imdb'/g,'from "/imdb.js"')
		body = body.replace(/(import [^\n]*')(\w[^']*)(?=')/g) do(m,start,path)
			# console.log 'rewrite',path,'to',"/repl/examples/{path}"
			start + "/repl/examples/{path}"

		let result = imbac.compile(body,{
			platform: 'web',
			sourcePath: file.path,
			format: 'esm',
			resolve: ResolveMap
		})
		file.js = result.toString!
	catch e
		console.log 'error compiling',e
		return
	return file.js

class File
	constructor service, data
		service = service
		name = data.name
		path = data.path
		body = data.body

	get ext
		$ext ||= name.split('.').pop!


class Service
	static def forClient client
		services[client.id] ||= new self(client)

	constructor client, options = {}
		owner = client
		options = options
		promises = {}
		files = {}
	
	def readFile path
		if files[path]
			return files[path]
		
		promises[path] ||= new Promise do(resolve)
			let result = await rpc('resolvePath',path)
			# console.log 'resolvePath',path,result
			cacheFile(path,result)
			return resolve(result)

	def cacheFile path, file
		files[path] = file

	def updateFile entry
		# console.log 'update file',path,body
		let file = files[entry.path]
		unless file
			file = files[entry.path] = entry
		else
			file.body = entry.body

		# compare with previous version etc
		if (/\.imba$/).test(entry.path)
			let js = compileImba(file)
			return js
		return

	def compileFile path, body, options = {}
		self

	def onmessage e
		if e.data isa Array
			# console.log 'sw message from service',e.data
			let [action,params] = e.data
			let result = null
			if self[action]
				result = await self[action](...params)
				e.ports[0].postMessage(result)

	def rpc action, ...params
		new Promise do(resolve,reject)
			const channel = new MessageChannel
			channel.port1.onmessage = do(event) resolve(event.data)
			owner.postMessage([action,params], [channel.port2])


class Worker

	constructor
		for ev in ['message','fetch','install','activate']
			global.addEventListener(ev,self["on{ev}"].bind(self))
		self

	def log ...params
		console.log(...params)
		self

	def onmessage e
		console.log "worker onmessage",e

		let cli = Service.forClient(e.source)
		if cli
			cli.onmessage(e)

		if e.data isa Array
			return

		# console.log 'sw onmessage',e,cli

		if e.data.event == 'compile'
			# console.log 'sw compile',e.data.body
			let js = compileImba(e.data)
			return e.source.postMessage({event: 'compiled',ref: e.data.ref, source: e.data.body, js: js})

		return

	def oninstall e
		log e
		global.skipWaiting!
		e.waitUntil
		return
	
	def onactivate e
		log e
		e.waitUntil global.clients.claim!
		# let bridge = await getBridge!
		self

	def getBridge
		let clients = await global.clients.matchAll({includeUncontrolled: false})
		for client in clients
			if client.url.indexOf("__blank__.html") >= 0
				return client
		return null

	def onfetch e
		let url = new URL(e.request.url)
		let clientId = e.resultingClientId or e.clientId or e.targetClientId
		
		#scope ||= url.pathname.slice(0,url.pathname.indexOf('/',1))		
		
		let path = url.pathname.replace(/^\/repl(-\d+)?/,'')	
		let name = path.split('/').pop!
		let basename = name.replace(/\.\w+$/,'')
		let ext = name.slice(basename.length + 1)

		if path == '/__blank__.html'
			let resp = new Response("Ok",status: 200,headers: {'Content-Type': 'text/html;charset=utf-8'})
			return e.respondWith(resp)

		

		if url.pathname.match(/__(\w+)__/)
			return

		# trying to fetch something outside of this
		if url.pathname == path
			return

		let responder = new Promise do(resolve)
			let handler = await getBridge!
			let t0 = Date.now!

			# console.log 'sw respond',url.pathname,#scope,url.pathname != path,!!handler,nr

			if name.match(/\.imba\.html/)
				# console.log "return html for imba example?"
				let js = 'try { window.frameElement.replify(this) } catch(e){ }'
				let body = "<script>window.ServiceSessionID = '{clientId}'; window.ImbaFiles = \{\}; {js}</script>" + indexTemplate.replace(/index\.imba/g,basename)
				let resp = new Response(body,status: 200,headers: {'Content-Type': 'text/html'})
				return resolve(resp)

			# unless service
			#	let resp = new Response("Whoops",status: 404,headers: {'Content-Type': 'text/plain'})
			#	return resolve(resp)
			let service = Service.forClient(handler)

			# console.log 'getting file',service,path

			let file = await service.readFile(path)

			# console.log 'got file!',file

			if file
				let ext = file.name.split('.').pop!

				let status = 200
				let mime = mimeTypeMap[ext] or mimeTypeMap.html
				let body = file.body

				if ext == 'html'
					let js = 'try { window.frameElement.replify(this) } catch(e){ }'
					body = "<script>window.ServiceSessionID = '{clientId}'; window.ImbaFiles = \{\}; {js}</script>" + body
				elif ext == 'imba'
					body = file.js or compileImba(file)
					body = "ImbaFiles['{file.path}']=1;\n" + body

				let resp = new Response(body,status: status,headers: {'Content-Type': mime})
				# console.log 'responding',Date.now! - t0
				resolve(resp)
			else
				let resp = new Response("Resource not found",status: 404,headers: {'Content-Type': 'text/html;charset=utf-8'})
				resolve(resp)

		return e.respondWith(responder)

const worker = new Worker

global.INSPECT = do
	let clients = await global.clients.matchAll({})
	console.log clients

global.SEND = do(msg)
	let clients = await global.clients.matchAll({})
	for client in clients
		client.postMessage("from sw: {msg}!!")