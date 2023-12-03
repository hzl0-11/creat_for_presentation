
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


gPlayTable.CreatePlay{

firstState = "testWrilRoundBall",
["testWrilRoundBall"] = {
        switch = function()
                if bufcnt(player.infraredCount("a") > 1 , 5) then                                                
                        return "testWrilRoundBall-whirlRobot"                    
                end
        end,
        a = whtCommonTask.goCmuRush(ball.pos,dir.playerToBall,_, flag.allow_dss+flag.dribbling),
        match = "(a)"
},

["testWrilRoundBall-whirlRobot"] = {
        switch = function()             
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,500),"机器人速度   " .. tostring(player.velMod("a")))

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"前后帧速度差值   " .. tostring(subSpeed()))

                if bufcnt(player.infraredCount("a") < 1,5) then
                        return "testWrilRoundBall"
                -- 旋转完成后,停止 
                elseif math.abs(player.toTheirGoalDir("a")-player.dir("a")) < 0.01 then
                        return "testWrilRoundBall-stoot"
                end 
        end,
        a = whtAttackTask.CSwhirlRobotToShoot("a"),
        match = "{a}"
},


["testWrilRoundBall-stoot"] = {
    switch = function()
        if player.kickBall("a") then
            return "testWrilRoundBall-stop"
        end 
    end,
        a = whtAttackTask.directShoot(),
        match = "{a}"
},



["testWrilRoundBall-stop"] = {
        switch = function() 
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"前后帧速度差值   " .. tostring(subSpeed()))
        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},


--结束



name = "test1-23",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
