
local DSS_FLAG = flag.allow_dss + flag.dodge_ball



function preDirSubnowDir()
        -- 初始设为0
    local preDir = 0
    local nowDir = 0
    local subDir = 0
    local PreDir = function ()        
            return preDir
    end   
    local NowDir = function ()        
             if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                nowDir = ball.velDir()
            end 
            subDir = nowDir - preDir
            if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                preDir = ball.velDir()
            end  
            return nowDir
    end
    local SubDir = function ()       
        return subDir
    end
 
    return PreDir,NowDir,SubDir
end

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


--得到当前帧,相差值,前一帧值(弧度)
local  preDir,nowDir,subDir = preDirSubnowDir()
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
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1200),"前后帧弧度差值   " .. tostring(subDir()))

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"前后帧速度差值   " .. tostring(subSpeed()))
            if player.kickBall("a") then
                return "stopPassBall"
            end 
        end,
        a = whtAttackTask.directPassBall("a","b",800),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},



["stopPassBall"] = {
        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"前后帧速度差值   " .. tostring(subSpeed()))
        end,
        a  = whtCommonTask.stop(),
        b  = whtCommonTask.stop(),
        match = "{ab}"
},


name = "test1-15",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
