--[[
  Full CV build only: unwrap markers so HTML has no cv-detailed-only or
  cv-education-date-range attributes. Replaces Div/Span nodes with their
  inner content (blocks / inlines).
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
    return div.content
  end
end

function Span(span)
  if has_class(span.classes, "cv-detailed-only") then
    return span.content
  end
end
