import {SiteWidth} from './SiteWidth'

export tag NavBar
	css
		.navitem c:$text-color
		.navitem@hover c:$link-hover-color td:underline 
		.navitem.active c:$text-color
	<self>
		<div.navbar[bdb:1px solid gray3]>
			<SiteWidth>
				<div[d:flex jc:space-between ai:center h:75px]>
					<a.logo[d:block cursor:pointer] route-to="/">
						<app-logo[d:flex w:150px c:$text-color]>
					<div.nav[d:group g:20px]>
						<a.navitem href="#"> "Getting Started Guide"
						<a.navitem href="#"> "Documentation"
						<a.navitem href="#"> "Github"
						<a.navitem href="#"> "Discord"
