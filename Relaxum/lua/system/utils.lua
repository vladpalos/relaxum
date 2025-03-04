--==================================================================================================
--  Copyright (c) 2010-2012 Red Fruits Games, Inc.
--  All Rights Reserved.
--  http://www.redfruits.com
--==================================================================================================

local M = {}


----------------------------------------------------------------------------------------------------
-- Global functions
----------------------------------------------------------------------------------------------------
-- Timer -------------------------------------------------------------------------------------------

function M.setInterval( func, delay )
    local timer = MOAITimer.new( MOAITimer.NORMAL )
    timer:setSpan( delay )
    timer:setMode( MOAITimer.CONTINUE )
    timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, func )
    timer:start()
    return timer
end

function M.setTimeout( func, delay )
    local timer = MOAITimer.new( MOAITimer.NORMAL )
    timer:setSpan( delay )
    timer:setMode( MOAITimer.NORMAL )
    timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, func )
    timer:start()
    return timer
end

-- Threads -----------------------------------------------------------------------------------------

function M.wait ( action )
    while action:isBusy () do coroutine:yield () end
end

-- Tables ------------------------------------------------------------------------------------------

function M.isArray( array )

    for k, _ in pairs(array) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true --Found nothing but numbers !
end

-- Used for queue, and stacks (better, faster)
function M.newList ()

    local List = {
        first = 0,
        last = -1
    }

    function List:pushleft (value)
      local first = self.first - 1
      self.first = first
      self[first] = value
    end

    function List:pushright (value)
      local last = self.last + 1
      self.last = last
      self[last] = value
    end

    function List:popleft ()
      local first = self.first
      if first > self.last then error("list is empty") end
      local value = self[first]
      self[first] = nil        -- to allow garbage collection
      self.first = first + 1
      return value
    end

    function List:popright (self)
      local last = self.last
      if self.first > last then error("list is empty") end
      local value = self[last]
      self[last] = nil         -- to allow garbage collection
      self.last = last - 1
      return value
    end

    return List
end

-- Bit operations ----------------------------------------------------------------------------------

local XOR_l = { {0,1}, {1,0} }
local BMASK = 2 ^ 32 - 1

function M.bitXor( a, b, c, ... )
    if c then
        return M.bitXor( M.bitXor( a, b ), c, ... )
    elseif b then
       pow = 1
       c = 0
       while a > 0 or b > 0 do
          c = c + ( XOR_l[ (a % 2) + 1 ][ (b % 2) + 1 ] * pow )
          a = math.floor( a / 2 )
          b = math.floor( b / 2 )
          pow = pow * 2
       end
       return c
    elseif a then
        return a
    end
end

function M.bitNot( a )
   return BMASK - a
end

function M.bitAnd( a, b, c, ... )
    if c then
        return M.bitAnd( M.bitAnd( a, b ), c, ... )
    elseif b then
       return ( (a + b) - M.bitXor( a, b ) ) / 2
    elseif a then
        return a
    end
end

function M.bitOr( a, b, c, ... )
    if c then
        return M.bitOr( M.bitOr( a, b ), c, ... )
    elseif b then
        return BMASK - M.bitAnd( BMASK - a, BMASK - b)
    elseif a then
        return a
    end
end
----------------------------------------------------------------------------------------------------
function M.print( obj, name )

  if name then
    io.write( "\nObject [" .. name .. " ] " )
  else
    io.write( "\nObject " )
  end

  if not obj then
    io.write( "is NIL !" )
    return
  end

  print()

  for k, v in pairs( obj ) do
    print( k,v )
  end
end

-- Do not call unrequire on a shared library based module unless you are 100% confidant that nothing uses the module anymore.
-- @param m Name of the module you want removed.
-- @return Returns true if all references were removed, false otherwise.
-- @return If returns false, then this is an error message describing why the references weren't removed.
function M.unrequire(m)

  package.loaded[m] = nil
  _G[m] = nil

  -- Search for the shared library handle in the registry and erase it
  local registry = debug.getregistry()
  local nMatches, mKey, mt = 0, nil, registry['_LOADLIB']

  for key, ud in pairs(registry) do
    if type(key) == 'string' and type(ud) == 'userdata' and getmetatable(ud) == mt and string.find(key, "LOADLIB: .*" .. m) then
      nMatches = nMatches + 1
      if nMatches > 1 then
        return false, "More than one possible key for module '" .. m .. "'. Can't decide which one to erase."
      end
      mKey = key
    end
  end

  if mKey then
    registry[mKey] = nil
  end

  return true
end


----------------------------------------------------------------------------------------------------
return M




