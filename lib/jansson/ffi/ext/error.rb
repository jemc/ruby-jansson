
module Jansson
  module FFI
    class Error
      
      def description(source_string)
        row = self[:line]
        col = self[:column]
        msg = self[:text].to_s
        
        source = source_string.each_line.to_a[row - 1].strip
        arrow  = ' ' * (col - 1) + '^'
        
        if source.length > 40
          if col >= 20
            source = '... ' + source.slice(col - 20, 40) + ' ...'
            arrow  = '    ' + arrow .slice(col - 20, 40)
          else
            source = source.slice(0, 40) + ' ...'
            arrow  = arrow .slice(0, 40)
          end
        end
        
        "near line: #{row}, column: #{col}: #{msg}\n#{source}\n#{arrow}"
      end
      
    end
  end
end
