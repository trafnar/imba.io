
export tag SiteWidth
	def render
		<self>
			<div[max-width:$site-width mx:auto px:20px d:block]>
				<slot>
