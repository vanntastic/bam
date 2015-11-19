module BamHelpers
  # terminal column width
  def col_width
    `stty size`.split(" ").last.to_i
  end
  
  def border
    "="*col_width
  end
  
  def wrap_top(content)
    "#{border}\n#{content}"
  end 

  def wrap_borders(content)
    "#{border}\n#{content}\n#{border}"
  end
end