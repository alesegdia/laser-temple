local util = {}

util.mergeAtFirst = function(tsrc, tdst)
  for k,v in pairs(tdst) do
    tsrc[k] = v
  end
end

util.replace_vars = function(str, vars)
  -- Allow replace_vars{str, vars} syntax as well as replace_vars(str, {vars})
  if not vars then
    vars = str
    str = vars[1]
  end
  return (string.gsub(str, "({([^}]+)})",
    function(whole,i)
      return vars[i] or whole
    end))
end

return util
