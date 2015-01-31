module MkIndex
  class << self
    def run(dir)
      str = ""
      str << "module.exports =\n"
      sources(dir).each do |src|
        str << "  #{src}: require './#{src}'\n"
      end
      index_file = "#{dir}/index.coffee"
      File.open(index_file,"w") do |f|
        f.print str
      end
      puts "(Wrote #{index_file})"
    end


    def sources(dir)
      [".js", ".coffee"].flat_map do |ext|
        file_basenames(dir, ext)
      end.reject do |src|
        src == 'index'
      end
    end

    def file_basenames(dir,ext)
      Dir["#{dir}/*#{ext}"].map { |f| File.basename(f,ext) }
    end
  end
end
