module css

import os
import regex

const object_regex = 'object\\s+(.+)?\\s+(\\{(.*)?\\})'
const inherits_regex = 'inherit\\s+(.+)?;'
const vcss_regex = '(${object_regex})|(${inherits_regex})'

pub fn parse(in_path string, out_path string) {
	mut objects := map[string]string{}

	to_parse := os.read_file(in_path) or {
		println(err)
		panic('Failed to open file: ${in_path}')
	}

	mut re := regex.new()
	re.compile_opt(vcss_regex) or {
		println(err)
		panic('Failed to compile regex: ${vcss_regex}')
	}
	parsed := re.replace_by_fn(to_parse, fn [mut objects] (re regex.RE, in_text string, start int, end int) string {
		group := in_text[start..end]
		split := group.split(' ')
		kind := split[0].trim_space()

		if kind == 'object' {
			name := split[1].trim_space()
			code := group.split('{')[1].trim_space()#[..-1].trim_space()
			objects[name] = code
			return ''
		} else if kind == 'inherit' {
			name := split[1]#[..-1].trim_space()
			if name !in objects {
				panic('error: object does not exist: `${name}`')
			}
			return objects[name]
		}

		return ''
	})

	os.mkdir_all(os.dir(out_path)) or {
		println(err)
		panic('Failed to create path to ${out_path}')
	}

	mut out_file := os.create(out_path) or {
		println(err)
		panic('Failed to create or open file: ${out_path}')
	}

	out_file.writeln(parsed) or {
		println(err)
		panic('Failed to write to file: ${out_path}')
	}
}
