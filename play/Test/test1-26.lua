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







gPlayTable.CreatePlay{

firstState = "testGoalie",
-- 守门员函数测试
--抢球
["testGoalie"] = {
        switch = function()
                 if bufcnt(player.infraredCount("a") > 1 , 3) then                                             
                        return "testGoalie-whirlRobot"
                end
        end,
        a = whtCommonTask.goCmuRush(ball.pos,dir.playerToBall,_, flag.allow_dss+flag.dribbling),
        Goalie = whtDefTask.luaGoalie(),
        match = "{a}"
},

-- 旋转机器人
["testGoalie-whirlRobot"] = {
        switch = function()
                debugEngine:gui_debug_line(ball.pos(),ball.pos()+Utils.Polar2Vector(2000 ,ball.velDir()),1); 
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(2000 ,player.dir("a")),6);
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(2000 ,player.toBallDir("a")),4);  
                
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,-2500),"球的速度:   "..tostring(ball.velMod()),2)          
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))

                if bufcnt(player.infraredCount("a") < 1,5) then
                        return "testGoalie"
                elseif math.abs(player.toTheirGoalDir("a")-player.dir("a")) < 0.01 then
                        return "testGoalie-shoot"               
                end 
        end,
        a = whtAttackTask.CSwhirlRobotToShoot("a"),
        Goalie = whtDefTask.luaGoalie(),
        match = "(a)"
},
--射门
["testGoalie-shoot"] = {
        switch = function()     
                debugEngine:gui_debug_x(CGeoPoint:new_local(param.pitchLength/2,0))
                debugEngine:gui_debug_line(ball.pos(),CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2),1); 
                debugEngine:gui_debug_line(ball.pos(),CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2),1); 

                debugEngine:gui_debug_line(ball.pos(),ball.pos()+Utils.Polar2Vector(5000 ,ball.toEnemyDir(0)),1); 
                debugEngine:gui_debug_line(ball.pos(),ball.pos()+Utils.Polar2Vector(5000 ,ball.velDir()),2); 
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(5000 ,player.dir("a")),6);
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(5000 ,player.toBallDir("a")),4);  

                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,-2500),"球的速度:   "..tostring(ball.velMod()),2)          
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))
                if player.kickBall("a") then
                        return "testGoalie-stop"
                end 
        end,
        a = whtAttackTask.directShoot(),
        Goalie = whtDefTask.luaGoalie(),
        match = "{a}"
},

["testGoalie-stop"] = {
        switch = function()     
                debugEngine:gui_debug_x(CGeoPoint:new_local(param.pitchLength/2,0))
                debugEngine:gui_debug_line(ball.pos(),CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2),1); 
                debugEngine:gui_debug_line(ball.pos(),CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2),1); 

                debugEngine:gui_debug_line(ball.pos(),ball.pos()+Utils.Polar2Vector(5000 ,ball.toEnemyDir(0)),1); 
                debugEngine:gui_debug_line(ball.pos(),ball.pos()+Utils.Polar2Vector(5000 ,ball.velDir()),2); 

                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,-2500),"球的速度:   "..tostring(ball.velMod()),2)          
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1200),"前后帧弧度差值   " .. tostring(subDir()))
                if bufcnt(true, 180) then
                        return "testGoalie"
                end 
        end,
        a = whtCommonTask.stop(),
        Goalie = whtDefTask.luaGoalie(),
        match = "{a}"
},
-- 结束


name = "test1-26",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
