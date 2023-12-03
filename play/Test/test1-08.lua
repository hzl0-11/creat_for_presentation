
function previousBallPosAndDir()
        -- 初始设为0
    local x = CGeoPoint:new_local(0,0)
    local dir = 0
    local mod = 0
    local b2x = function ()        
        if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值给X ,不在,保值X原值
                x = CGeoPoint:new_local(ball.posX(),ball.posY())
        end 
        return x
    end
    local b2dir = function ()        
        if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                dir = ball.velDir()
        end 
        return dir
    end
     local b2mod = function ()        
        if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值
                mod = ball.velMod()
        end 
        return mod
    end
    return b2x, b2dir,b2mod
end



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




--如果球消失或出界, 此值为消失前或出界前的值, 否则为当前值
local fx,fdir,fmod = previousBallPosAndDir()
--得到当前帧,相差值,前一帧值(弧度)
local  preDir,nowDir,subDir = preDirSubnowDir()
--得到当前帧,相差值,前一帧值(速度)
local  preSpeed,nowSpeed,subSpeed = preSpeedSubnowSpeed()


gPlayTable.CreatePlay{

firstState = "testBallPoint",

["testBallPoint"] = {

        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,2000),"消失前(场外前)球的X坐标   " .. tostring(fx():x()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1500),"消失前(场外前)球的弧度   " .. tostring(fdir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,1000),"消失前(场外前)球的速度   " .. tostring(fmod()))               

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-200),"前帧弧度   " .. tostring(preDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-700),"当前帧弧度   " .. tostring(nowDir()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1200),"前后帧弧度差值   " .. tostring(subDir()))

                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1500),"前帧速度   " .. tostring(preSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"当前帧速度   " .. tostring(nowSpeed()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2500),"前后帧速度差值   " .. tostring(subSpeed()))

        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},



name = "test1-08",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
