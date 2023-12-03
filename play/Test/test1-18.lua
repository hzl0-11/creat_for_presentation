
local DSS_FLAG = flag.allow_dss + flag.dodge_ball
function preSpeedSubnowSpeed()
        -- 初始设为0
    local preSpeed = 0
    local nowSpeed = 0
    local subSpeed = 0
    local PreSpeed = function ()             
            return preSpeed
    end    
    local NowSpeed = function ()        
             if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                nowSpeed = ball.velMod()
             end
             subSpeed = nowSpeed - preSpeed 
             if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                preSpeed = ball.velMod()
             end 
             return nowSpeed
    end

    local SubSpeed = function ()        
        return subSpeed
    end

    return PreSpeed,NowSpeed,SubSpeed
end



--得到当前帧,相差值,前一帧值(速度)
local  preSpeed,nowSpeed,subSpeed = preSpeedSubnowSpeed()



--发球机器人去的位置
local preparePos = function(dist)
    return function()
      local idir = (pos.ourGoal() - ball.pos()):dir()
      local iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
      return iPos
    end 
end


gPlayTable.CreatePlay{

firstState = "begin",
["begin"]  = {
        switch = function() 
                if bufcnt(player.toTargetDist("a") < 20  ,3) then                         
                    return "preparePass-b" 
                end
        end,
        a = whtCommonTask.goCmuRush(preparePos(160), dir.playerToBall,_, DSS_FLAG),
        b = whtCommonTask.goCmuRush(CGeoPoint:new_local(-2000,-2*param.pitchWidth/18),dir.playerToBall,_, DSS_FLAG),
        match    = "{ab}"
},

-- 通过旋转准备转球
["preparePass-b"] = {
        switch = function()                   
                if bufcnt(player.toTargetDist("a") < 20  ,3) then     
                        return "flatBall-b"
                end                       
        end,
        a = whtAttackTask.aroundBallToRobot("a","b",160),
        b = whtCommonTask.goCmuRush(CGeoPoint:new_local(-2000,-2*param.pitchWidth/18),dir.playerToBall,_, DSS_FLAG),
        match = "{ab}"
},




--传球给b
["flatBall-b"] = {
        switch = function()
            if player.kickBall("a") then
                return "stopPassBall"
            end 
        end,
        a = whtAttackTask.testPower("a","b",kick.flat,5000,500,1000),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},



["stopPassBall"] = {
        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"平传    前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"       当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"       前后帧速度差值   " .. tostring(subSpeed()))
            if bufcnt(true, 180) then
                return "flatBall-b2"
            end        
        end,
        a  = whtCommonTask.stop(),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},

--传球给b2
["flatBall-b2"] = {
        switch = function()
            if player.kickBall("a") then
                return "stopPassBall2"
            end 
        end,
        a = whtAttackTask.testPower("a","b",kick.chip,2500,500,1000),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},



["stopPassBall2"] = {
        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"挑传     前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"        当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"        前后帧速度差值   " .. tostring(subSpeed()))      
        end,
        a  = whtCommonTask.stop(),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},


name = "test1-18",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
