module Spec
  module Helpers
    def lib
      File.expand_path('../../../lib', __FILE__)
    end
    
    def ruby(opts, ruby = nil)
        ruby, opts = opts, nil unless ruby
        ruby.gsub!(/(?=")/, "\\")
        ruby.gsub!('$', '\\$')
        out = %x{#{Gem.ruby} -I#{lib} #{opts} -e "#{ruby}"}.strip
        @exitstatus = $?.exitstatus
        out
      end
  end
end