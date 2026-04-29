--[[
  Abbreviated CV build only: drop content marked for the full CV.
  Targets: Div.cv-detailed-only, Span.cv-detailed-only, Para.cv-education-date-range
]]

local function has_class(classes, name)
  if not classes then
    return false
  end
  for _, c in ipairs(classes) do
    if c == name then
      return true
    end
  end
  return false
end

function Div(div)
  if has_class(div.classes, "cv-detailed-only")
      or has_class(div.classes, "cv-education-date-range") then
    return {}
  end
end

function Span(span)
  if has_class(span.classes, "cv-detailed-only") then
    return {}
  end
end

