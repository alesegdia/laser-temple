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

util.remove_if = function(t, fn)
  for i=#t,1,-1 do
    if fn(t[i]) then
      table.remove(t, i)
    end
  end
end

util.deepcopy = function (orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return util
