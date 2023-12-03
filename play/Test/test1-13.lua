
local DSS_FLAG = flag.allow_dss + flag.dodge_ball

pos1 = CGeoPoint:new_local(0,0)
pos2 = CGeoPoint:new_local(0,0)

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
                -- if  math.abs(dir.playerToBall("a")-player.toPlayerDir("a","b")) < 0.04 then
                        pos1 = CGeoPoint:new_local(ball.posX(),ball.posY())
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
                pos2 = CGeoPoint:new_local(ball.posX(),ball.posY())
                return "stopPassBall"
            end 
        end,
        a = whtAttackTask.dribblingPassBall("a","b",1000),
        -- a = whtAttackTask.dribblingPassBall("a","b"),
        -- a = whtAttackTask.directShoot(),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},



["stopPassBall"] = {
        switch = function()
            debugEngine:gui_debug_x(pos1,1)
            debugEngine:gui_debug_x(pos2,3)
            debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,2500),"球的移动距离:"..tostring(pos1:dist(pos2)),2)
        end,
        a  = whtCommonTask.goCmuRush(CGeoPoint:new_local(0,0),dir.playerToBall,_, DSS_FLAG),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},


name = "test1-13",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
