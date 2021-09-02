import express from 'express'
import np from 'path'
import nfs from 'fs'

const app = express!

const imbac = require 'imba/compiler'

import examples from './public/examples.json'

app.get(/__sw(_\d+)?__\.js/) do(req,res)
	const asset = import('./src/sw/worker.imba?as=webworker')
	res.sendFile asset.absPath

app.use(express.static('public'))

app.get(/__blank__\.html/) do(req,res)
	res.send String <div>

app.get(/^\/repl-\d+\//) do(req,res)
	return res.sendStatus(404)

const indexTemplate = "
<html>
	<head>
		<meta charset='UTF-8'>
		<title>Playground</title>
		<script>try \{ window.frameElement.replify(this) \} catch(e)\{\}</script>
		<link href='/preflight.css' rel='stylesheet'>
	</head>
	<body>
		<script type='module' src='/examples/helpers.imba'></script>
		<script type='module'>
			import * as example from './index.imba';
			try \{ window.expose(example || \{\});\} catch(e)\{\}
		</script>
	</body>
</html>"

const ResolveMap = {
	'imba': import('./src/imba.imba?as=web,module').url
	'imdb': '/imdb.js'
}

def compileImba file
	try
		let body = file.body
		# enforce tabs
		body = body.replace(/[ ]{4}/g,'\t')
		# rewrite certain special things
		body = body.replace(/# @(show|log)( .*)?\n(\t*)/g) do(m,typ,text,tabs)
			m + "${typ} '{(text or '').trim!}', "
		body = body.replace(/from 'imdb'/g,'from "/imdb.js"')
		body = body.replace(/(import [^\n]*')(\w[^']*)(?=')/g) do(m,start,path)
			# console.log 'rewrite',path,'to',"/repl/examples/{path}"
			start + "/examples/{path}"

		let result = imbac.compile(body,{
			platform: 'web',
			sourcePath: file.path,
			format: 'esm',
			resolve: ResolveMap
		})
		file.js = result.toString!
	catch e
		console.log 'error compiling',e,file.path
		return
	return file.js


# responding to the code
app.get('/examples/*') do(req,res)
	let path = req.url
	let file = examples[path]
	let nohtml = path.replace(/\.html$/,'')
	let ext = np.extname(path)
	console.log "responding to",req.url,path,!!file

	if !file and examples[nohtml]
		res.type('html')
		return res.send indexTemplate.replace("index.imba",np.basename(nohtml))

	if !file and examples[path + '.imba']
		file = examples[path = (path + (ext = '.imba'))]

	if file
		let body = file.body
		
		if ext == '.imba'
			# console.log 'compile imba file',path
			unless file.js
				file.path ||= path
				compileImba(file)
			
			body = file.js
			res.type('js')

		return res.send(body)
	
	return res.sendStatus(404)



# app.get('/__sw__.html') do(req,res)
# 	let js = assets['__sw__bridge.js']
# 	let html = <div>
# 		<script type='text/javascript' innerHTML=js.body>
# 	res.send html.toString!
# catch-all should always render the index
app.get(/\.*/) do(req,res)
	# console.log 'handling',req.url,req.accepts(['image/*', 'html'])
	# only render the html for requests that prefer an html response
	unless req.accepts(['image/*', 'html']) == 'html'
		return res.sendStatus(404)

	res.send String <html>
		<head>
			<meta charset="UTF-8">
			<title> "Imba - The friendly full-stack language!"
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
			<meta name="description" content="Imba is a programming language for building web applications with insane performance. You can use it both for the server and client.">
			# this is the documentation / content generated by npm run build-content
			# loaders for asynchronously loading the monaco code editor
			<script src="/monaco/min/vs/loader.js">
			<script innerHTML='''
				require.config({ paths: { vs: "/monaco/min/vs" } });
				window.loadMonaco = function (cb) { require(["vs/editor/editor.main"], cb) };
			'''>
			# <!-- Favicon -->
			<link rel="apple-touch-icon" sizes="57x57" href="/images/apple-icon-57x57.png">
			<link rel="apple-touch-icon" sizes="60x60" href="/images/apple-icon-60x60.png">
			<link rel="apple-touch-icon" sizes="72x72" href="/images/apple-icon-72x72.png">
			<link rel="apple-touch-icon" sizes="76x76" href="/images/apple-icon-76x76.png">
			<link rel="apple-touch-icon" sizes="114x114" href="/images/apple-icon-114x114.png">
			<link rel="apple-touch-icon" sizes="144x144" href="/images/apple-icon-144x144.png">
			<link rel="apple-touch-icon" sizes="152x152" href="/images/apple-icon-152x152.png">
			<link rel="icon" type="image/png" sizes="144x144" href="/images/android-icon-144x144.png">
			<link rel="icon" type="image/png" sizes="192x192" href="/images/android-icon-192x192.png">
			<link rel="icon" type="image/png" sizes="152x152" href="/images/android-icon-152x152.png">
			<link rel="icon" type="image/png" sizes="36x36" href="/images/android-icon-36x36.png">
			<link rel="icon" type="image/png" sizes="48x48" href="/images/android-icon-48x48.png">
			<link rel="icon" type="image/png" sizes="72x72" href="/images/android-icon-72x72.png">
			<link rel="icon" type="image/png" sizes="96x96" href="/images/android-icon-96x96.png">
			<link rel="icon" type="image/png" sizes="16x16" href="/images/favicon-16x16.png">
			<link rel="icon" type="image/png" sizes="32x32" href="/images/favicon-32x32.png">
			<link rel="icon" type="image/png" sizes="64x64" href="/images/favicon-64x64.png">
			<link rel="icon" type="image/png" sizes="96x96" href="/images/favicon-96x96.png">

			# <!-- <link rel="manifest" href="/manifest.json"> -->
			<meta name="msapplication-TileColor" content="#ffffff">
			<meta name="msapplication-TileImage" content="/images/ms-icon-144x144.png">
			<meta name="theme-color" content="#ffffff">


			# <!-- Google / Search Engine Tags -->
			<meta itemprop="name" content="Imba - The friendly full-stack language">
			<meta itemprop="description" content="Imba is a programming language for building web applications with insane performance. You can use it both for the server and client.">
			<meta itemprop="image" content="/images/social-card-preview.jpg">

			# <!-- Facebook Meta Tags -->
			<meta property="og:url" content="https://imba.io">
			<meta property="og:type" content="website">
			<meta property="og:title" content="Imba - The friendly full-stack language">
			<meta property="og:description" content="Imba is a programming language for building web applications with insane performance. You can use it both for the server and client.">
			<meta property="og:image" content="/images/social-card-preview.jpg">

			# <!-- Twitter Meta Tags -->
			<meta name="twitter:card" content="summary_large_image">
			<meta name="twitter:title" content="Imba - The friendly full-stack language">
			<meta name="twitter:description" content="Imba is a programming language for building web applications with insane performance. You can use it both for the server and client.">
			<meta name="twitter:image" content="/images/social-card-preview.jpg">

			# <!-- Work Sans font -->
			<link rel="preconnect" href="https://fonts.gstatic.com">
			<link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@900&family=Kalam:wght@400;700&display=swap" rel="stylesheet">
			# <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@400;600&display=swap" rel="stylesheet">
			<style src='*'>
		<body tabIndex='-1'>
			<script src="./public/content.json.js?as=iife">
			<script type="module" src="./src/index.imba">

# pass through imba serve to automatically
# serve assets in an optimised manner

imba.serve app.listen(process.env.PORT or 5000)