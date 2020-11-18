import '../app-logo'
import "fontsource-roboto"
import "fontsource-roboto/500-normal.css"
import "fontsource-work-sans/900-normal.css"



tag Graph
	imbaOpsFinal = 237462 
	imbaOps = 0
	reactOps = 8811
	vueOps = 7915
	opsScale = 30
	zoomScale = 1

	css .bar h:30px bgc:#A1AEBF my:20px c:#A1AEBF rd:2px

	def onIntersect
		imbaOps = imbaOpsFinal
		zoomScale = 0.08


	def render
		<self[d:block scale:{zoomScale} tween:all 2s linear 1s origin:0% 50%] @intersect=onIntersect>
			<SiteWidth[mt:100px]>
				<div[bgc:gray2 p:100px]>
					<div.bar[w:{imbaOps/opsScale}px bgc:#DF3989 c:#DF3989 tween:all 3s linear 1s]>
					<div.bar[w:{reactOps/opsScale}px]>
					<div.bar[w:{vueOps/opsScale}px]>

tag Glitch
	prop title
	prop offset = 0
	css
		d:block pos:relative h:100px
		.text pos:absolute fs:80px fw:bold
		.red c:#FA1420
		.blue c:#3DFEFE mix-blend-mode:multiply

	def handleMouseMove e
		offset = e.clientX/100 - 5

	boundMouseMove = (do(e)
		handleMouseMove(e)
		imba.commit!
	).bind(self)

	def mount
		document.addEventListener 'mousemove', boundMouseMove

	<self>
		<div.text.red[t:{offset}px l:{offset}px]> title
		<div.text.blue[t:{-offset}px l:{-offset}px]> title




global css
	@root
		--site-width: 900px
		--text-color: #313339
		--link-color: #5230F0
		--link-hover-color: #5230F0
		--light-text-color: gray8
	body
		font-family: roboto
		color: $text-color



tag SiteWidth
	<self[max-width:$site-width mx:auto px:20px d:block]>
		<slot>


tag NavBar
	css
		.navitem c:$text-color
		.navitem@hover c:$link-hover-color td:underline 
		.navitem.active c:$text-color
	<self>
		<div.navbar[bdb:1px solid gray3]>
			<SiteWidth[d:flex jc:space-between ai:center h:75px]>
				<a.logo[d:block cursor:pointer] route-to="/">
					<app-logo[d:flex w:150px c:$text-color]>
				<div.nav[d:group g:20px]>
					<a.navitem href="#"> "Getting Started Guide"
					<a.navitem href="#"> "Documentation"
					<a.navitem href="#"> "Github"
					<a.navitem href="#"> "Discord"

tag Intro
	css
		.button fw:500 fs:20px bgc:$link-color c:white rd:full d:block w:250px ta:center px:30px py:8px fw:500
		.tout c:var(--light-text-color) w:300px
		.tout@before content: "• " c:green5


	<self[d:block bgc:gray2 py:100px]>
		<SiteWidth>

			<div.explanation>
				<div[ff:'Work Sans' fw:bold fs:100px c:#5230F0]> "Build Fast"

				<p[c:$light-text-color fs:24px w:620px]>
					"""
					Smart syntax with built-in tags and styles let's you build things fast.
					A groundbreaking memoized DOM technique lets you build fast things.
					"""

				<a.button[my:45px] href="#"> "Start Learning Imba"
			

export tag Home
	<self>
		<NavBar>
		<Intro>
