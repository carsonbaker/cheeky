module Cheeky
  
  class CheekyController < ActionController::Base
    
    def show
      the_class     = params[:class]
      the_accessor  = params[:accessor]
      the_id        = params[:id]
      the_options   = params[:options]
      
      raise CheekyError, "Invalid class name" unless the_class =~ /^[a-zA-Z]\w*$/
      raise CheekyError, "Invalid id" unless the_id =~ /^\d*$/
      raise CheekyError, "Invalid accessor" unless the_accessor =~ /^[a-zA-Z]\w*$/
      
      input = Object.const_get(the_class).class_eval do
        self.find(the_id).instance_eval(the_accessor)
      end
      
      img_data = Cheeky::RenderTTF.render(input, the_options)
      
      respond_to do |format|
        format.png do
          send_data img_data, :disposition => 'inline', :type => "image/png"
        end
      end
    end
	end
	
end