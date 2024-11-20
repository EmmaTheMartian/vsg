import emmathemartian.vsg.html

fn index_page() html.HtmlElementOrString {
	return html.html([
		html.head([
			html.title('Example Page')
		])
		html.body([
			html.h1('Example Page')
			html.div([
				html.p('Example paragraph')
			])
		])
	])
}

fn test_html() {
	html.build('build/', {
		'index': index_page
	})
}
