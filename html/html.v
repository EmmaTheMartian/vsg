module html

import os

pub type ElementArg = HtmlElement | string | []HtmlElementOrString

pub type PageFn = fn () HtmlElementOrString

pub type HtmlElementOrString = HtmlElement | string

pub struct HtmlElement {
pub mut:
	kind string
	parameters map[string]string = {}
	children []HtmlElementOrString = []
	is_self_closing bool
	// Makes this element not trigger an indent when being compiled.
	no_indent bool
}

pub fn (elm HtmlElement) compile(indents int) string {
	indent := if elm.no_indent { '' } else { '\t'.repeat(indents) }
	mut compiled := indent + '<${elm.kind}'
	mut has_element_child := elm.children.any(|it| it is HtmlElement)

	for key, val in elm.parameters {
		compiled += ' ${key}="${val}"'
	}

	if !elm.is_self_closing {
		compiled += '>'

		for child in elm.children {
			match child {
				string { compiled += child }
				HtmlElement { compiled += '\n' + child.compile(indents + 1) }
			}
		}

		if has_element_child {
			compiled += '\n${indent}'
		}

		compiled += '</${elm.kind}>'
	} else {
		compiled += '/>'
	}

	return compiled
}

@[inline] pub fn (elm HtmlElement) str() string {
	return elm.compile(0)
}

@[inline] pub fn (mut elm HtmlElement) add(child HtmlElement) {
	elm.children << child
}

@[inline] pub fn (mut elm_ HtmlElement) add_elm(kind string, params ElementParams) {
	elm_.add(elm(kind, params))
}

@[params]
pub struct ElementParams {
pub:
	parameters map[string]string = {}
	// shorthand for `parameters: { 'class': value }`
	class string
	// shorthand for `parameters: { 'id': value }`
	id string
	children []HtmlElementOrString = []
	is_self_closing bool
	no_indent bool
}

@[inline] pub fn elm(kind string, params ElementParams) HtmlElement {
	mut pars := params.parameters.clone()
	if params.class != '' {
		pars['class'] = params.class
	}
	if params.id != '' {
		pars['id'] = params.id
	}

	return HtmlElement{
		kind: kind
		parameters: pars
		children: params.children
		is_self_closing: params.is_self_closing
		no_indent: params.no_indent
	}
}

pub fn build(build_path string, pages map[string]PageFn) {
	for title, page in pages {
		returned := page()
		compiled_page := match returned {
			string { returned }
			HtmlElement { returned.compile(0) }
		}
		path := '${build_path}/${title}.html'

		os.mkdir_all(os.dir(path)) or {
			println(err)
			panic('vsg: failed to make directories to ${path}')
		}

		mut file := os.create(path) or {
			println(err)
			panic('vsg: could not create or open file at ${path}')
		}

		defer {
			file.close()
		}

		file.writeln('<!DOCTYPE html>') or {
			println(err)
			panic('vsg: could not write doctype to file at ${path}')
		}

		file.writeln(compiled_page) or {
			println(err)
			panic('vsg: could not write line to file at ${path}')
		}
	}
}
