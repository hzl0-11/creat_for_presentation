
--如果球在场内,由于视觉原因消失不见(或不在场内),如何得到前一个可见位置
-- 不能直接去得到二维坐标,需要分别得到x, y ,再组合成一个点返回
function previousBallPos()
        -- 初始设为0
    local x = CGeoPoint:new_local(0,0)
    return function ()        
        if whtCommonFunction.BallInField() then
                -- 如果球还在,赋值给X ,不在,保值X原值
                x = CGeoPoint:new_local(ball.posX(),ball.posY())
        end 
        return x
    end
end


local f1 = previousBallPos()


gPlayTable.CreatePlay{

firstState = "testBallPoint",

--球消失前的位置测试
--valid值测试
["testBallPoint"] = {

        switch = function()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,0),"消失前(场外前)球的X坐标   " .. tostring(f1():x()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-1000),"ball.valid的值   " .. tostring(ball.valid()))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(0,-2000),"消失时(场外时)球的X坐标   " .. tostring(ball.posX()))
        end,
        a = whtCommonTask.goCmuRush(f1,dir.playerToBall,_,flag.dribbling + flag.allow_dss),
        match = "{a}"
},
--结束


name = "test1-07",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
