module Cheeky
  
  class << self
    
    def options
      @options ||= { }
    end
    
    def path_for_command(command) #:nodoc:
      path = [options[:image_magick_path], command].compact
      File.join(*path)
    end
    
    def bit_bucket
      File.exists?("/dev/null") ? "/dev/null" : "NUL"
    end
  
    def run(cmd, params = "", expected_outcodes = 0)
      output = `#{%Q[#{path_for_command(cmd)} #{params} 2>#{bit_bucket}].gsub(/\s+/, " ")}`
      unless [expected_outcodes].flatten.include?($?.exitstatus)
        raise CheekyCommandLineError, "Error while running #{cmd}"
      end
      output
    end
  end
  
  class CheekyError < StandardError #:nodoc:
  end

  class CheekyCommandLineError < StandardError #:nodoc:
  end

  class NotIdentifiedByImageMagickError < CheekyError #:nodoc:
  end
  
  class RenderTTF
    
    @@font_store = "#{RAILS_ROOT}/vendor/plugins/cheeky/fonts/"
    
    @@default_options = {
      :pointsize => '29',
      :font => @@font_store + 'sketchrockwell.ttf',
      :background => %{"#F5F5EC"},
      :fill => %{"#000"},
      :gravity => "west",
      :crop => "+1+0",
    }
  
    def self.render(text, options = {})
      
      params = escaped_text = ''
      @@default_options.merge(self.parse_options(options)).each_pair do |k,v|
        params += "-#{k} #{v} "
      end
      
      text.each_char do |c|
        if c == %^"^
          c = "\\" + %^"^
        end
        escaped_text << c
      end
      
      begin
        #success = self.run("convert", command.gsub(/\s+/, " "))
        success = Cheeky.run(%^ echo "#{escaped_text}" | convert #{params} label:@- png:- ^)
      rescue CheekyCommandLineError
        raise CheekyError, "There was an error processing the image."
      end
      
    end
    
    # TODO: complete this function so that it breaks out query_string
    # delimited things and returns a hash
    def self.parse_options(options)
      {}
    end
    
  end
  
end