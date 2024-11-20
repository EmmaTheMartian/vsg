module html

import arrays

@[inline] pub fn a(text ElementArg, href string, params ElementParams) HtmlElement {
	return elm('a', ElementParams{
		...params,
		children: match text {
			HtmlElement { arrays.concat(params.children, text) }
			string { arrays.concat(params.children, text) }
			[]HtmlElementOrString { arrays.append(params.children, text) }
		},
		parameters: { ...params.parameters, 'href': href }
	})
}

@[inline] pub fn link(rel string, path string) HtmlElement {
	return elm('link', parameters: { 'rel': rel, 'href': path }, is_self_closing: true)
}
