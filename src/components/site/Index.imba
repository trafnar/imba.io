import '../app-logo'
import "fontsource-roboto"
import "fontsource-roboto/500-normal.css"
import "fontsource-work-sans/900-normal.css"
import {NavBar} from './NavBar'
import {SiteWidth} from './SiteWidth'

global css
	@root
		$site-width: 1120px
		$text-color: #313339
		$link-color: #5230F0
		$link-hover-color: #5230F0
		$light-text-color: gray8
	body
		font-family: roboto
		color: $text-color


export tag Home

	css
		.button fw:500 fs:20px bgc:$link-color c:white rd:full d:block w:250px ta:center px:30px py:8px fw:500
		.tout c:var(--light-text-color) w:300px
		.tout@before content: "• " c:green5
	
		.intro
			d:flex
			jc:space-between

		.glance
			shadow: 0 28px 36px rgba(46,37,87,0.08)
			bgc:white
			p:20px
			w:320px
			d:flex
			ai:center
			jc:center
			li
				fs:18px
				lh:50px
				@before
					content: "✓"
					c:green5
					mr: 5px

	def render
		<self>
			<NavBar>
			<SiteWidth[d:block bgc:gray2 py:100px]>
				<div.intro>

					<div.explanation>
						<div[ff:'Work Sans' fw:bold fs:100px c:#5230F0]> "Build Fast"
						<p[c:$light-text-color fs:24px w:560px fw:500]>
							"""
							Smart syntax with built-in tags and styles let's you build things fast. A groundbreaking memoized DOM technique lets you build fast things.
							"""
						<a.button[mt:45px] href="#"> "Start Learning Imba"
					
					<div.glance>
						<ul>
							<li> "Compiles to Javascript"
							<li> "Works with Javascript"
							<li> "Smart, Minimal Syntax"
							<li> "Groundbreaking Performance"
							<li> "Built-in Tags & Styles"
							<li> "Fun to Use"

