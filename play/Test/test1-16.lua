
local DSS_FLAG = flag.allow_dss + flag.dodge_ball


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
        a = whtAttackTask.testPower("a","b",kick.flat,6000,500,1000),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},



["stopPassBall"] = {
        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(ball.velMod()))
        end,
        a  = whtCommonTask.stop(),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},


name = "test1-16",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
