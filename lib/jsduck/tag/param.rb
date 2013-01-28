require "jsduck/tag/tag"
require "jsduck/doc/subproperties"

module JsDuck::Tag
  class Param < Tag
    def initialize
      @pattern = "param"
      @key = :param
      @merge_context = :method_like
    end

    # @param {Type} [name=default] (optional) ...
    def parse_doc(p)
      tag = p.standard_tag({:tagname => :param, :type => true, :name => true})
      tag[:optional] = true if parse_optional(p)
      tag[:doc] = :multiline
      tag
    end

    def parse_optional(p)
      p.hw.match(/\(optional\)/i)
    end

    def process_doc(h, tags, pos)
      h[:params] = JsDuck::Doc::Subproperties.nest(tags, pos)
    end

    def merge(h, docs, code)
      h[:params] = merge_params(docs, code)
    end

    private

    def merge_params(docs, code)
      explicit = docs[:params] || []
      implicit = code_matches_doc?(docs, code) ? (code[:params] || []) : []
      # Override implicit parameters with explicit ones
      # But if explicit ones exist, don't append the implicit ones.
      params = []
      (explicit.length > 0 ? explicit.length : implicit.length).times do |i|
        im = implicit[i] || {}
        ex = explicit[i] || {}
        params << {
          :type => ex[:type] || im[:type] || "Object",
          :name => ex[:name] || im[:name] || "",
          :doc => ex[:doc] || im[:doc] || "",
          :optional => ex[:optional] || false,
          :default => ex[:default],
          :properties => ex[:properties] || [],
        }
      end
      params
    end

    # True if the name detected from code matches with explicitly
    # documented name.  Also true when no explicit name documented.
    def code_matches_doc?(docs, code)
      return docs[:name] == nil || docs[:name] == code[:name]
    end
  end
end
