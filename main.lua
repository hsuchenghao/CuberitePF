--[[
local networking = require("networking")

local port = 8080

-- Create a server that listens for incoming connections on the specified port
local server = networking.server(port)

while true do
  -- Accept an incoming connection
  local client = server:accept()

  -- Forward the connection to the appropriate destination
  local destination = networking.connect("localhost", 80)
  local data = client:receive()
  destination:send(data)
end
--]]

local networking = require("networking")

local port = 8080

-- Create a server that listens for incoming connections on the specified port
local server = networking.server(port)

-- Create a table of destination servers
local destinations = {
  ["dest1"] = networking.connect("dest1.example.com", 80),
  ["dest2"] = networking.connect("dest2.example.com", 80),
  ["dest3"] = networking.connect("dest3.example.com", 80),
}

-- Define a function for determining which destination server to forward to
local function lookup_destination(data)
  -- Extract the destination from the incoming data
  local dest = string.match(data, "^dest=(%w+)")
  if dest then
    -- Look up the destination server in the table
    return destinations[dest]
  end
end

while true do
  -- Accept an incoming connection
  local client = server:accept()

  -- Look up the destination server for this connection
  local destination = lookup_destination(client:receive())
  if destination then
    -- Forward the connection to the destination
    local data = client:receive()
    destination:send(data)
  else
    -- If no destination was found, close the connection
    client:close()
  end
end