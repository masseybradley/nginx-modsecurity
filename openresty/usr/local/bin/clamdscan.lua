#!/usr/bin/lua

function fsize(filename)
   file = io.open(filename,"r")
   local current = file:seek()
   local size = file:seek("end")
   file:seek("set",current)
   file:close()
   return size
end

function main(filename)
   m.log(1,"Inspection for "..filename);
   local clamdscan  = "/usr/bin/clamdscan"

   local agent = "clamdscan"

   if fsize(filename) == 0 then
     return nil
   end

   local cmd = clamdscan .. " --fdpass --stdout --no-summary"

   local f = io.popen(cmd .. " " .. filename .. " || true")
   local l = f:read("*a")
   f:close()

   local isVuln = string.find(l, "FOUND")
   local isError = string.find(l, "ERROR")

   if isVuln then
     m.log(1, "[" .. agent .. " scanner message: " .. l .. "]\n")
     return 1
   elseif isError then
     return 2
   else
     return 0
   end
end
