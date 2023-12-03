module(..., package.seeall)		
local DSS_FLAG = flag.allow_dss + flag.dodge_ball

--1.1  守门员		
-- 					goalie(): 平台自带 
-- 					luaGoalie_1(): 防守直接射门 


-- 存在的问题:
-- 		从禁区平射踢球解围,容易出现球反弹进网
-- 		在左右靠近底线时防守效果好,其他位置防守效果不好(离禁区近的球很难防守)
-- 		原因是以防守球门中心点移动圆弧位置
function goalie()
	local mexe, mpos = Goalie()
	return {mexe, mpos}
end
-- 改进:  
-- 从禁区踢球解围,使用挑射
-- 靠近底线时防守,产用平台技能方式, 其他位置在球不向球门移动时产用平台方式,向球门移动时,向截球点移动去封堵射门线




-- 防守直接射门

-- 如果 球速低于 某个值，那么：
-- 		如果 球在禁区内，那么：	
-- 			向球移动，踢出
-- 		否则：
-- 			如果 球附近一定距离有对方机器人且弧度朝向球门内，那么：
-- 				移动到机器人弧度延长线上的截点
-- 			否则			
-- 				防守球和球门中点的连线上，离球门中点的距离为球门长度的一半-机器人的半径
-- 否则 
-- 		如果 球速度弧度朝向球门内  那么：
-- 			移动到球速度弧度延长线上的截点
-- 		否则：
-- 			防守球和球门中点的连线上，离球门中点的距离为球门长度的一半-机器人的半径

-- 修订： 
-- 1. 在守门员移动时，其中心点不能移动到球门端，X坐标大于（半场长度-球的半径）时，要等于（半场长度-球的半径）
-- 2. 截点 如果在球门内, 移动到球速度弧度延长线与球门线的交点上(X坐标要大于等于 半场长度-球的半径)
--  关于第二点,基本不会发生,因为守门员首先会跟着球防守


function luaGoalie_1()  
	local ipos = function()		
		--保存初始球的状态
		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempDir = -math.pi -- 保存当前帧的球的弧度
		return function(runner)
			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				tempDir = ball.velDir()
			end 
			-- 得到球的X，Y坐标值，为了判断是否在禁区内
			local x = tempXY:x()
			local y = tempXY:y()			
			--初始变量,球或机器人指向球门二边的弧度
			local tempDir1  
			local tempDir2
			-- 初始变量,记录对方机器人的弧度和位置
			local enemyDir
			local enemyP
			-- 防守位标志,1表示防守球与球门中点的连线,2表示防守球延长线上的垂直点,3表示防守机器人延长线上的垂直点
			local flag = 1 

			-- 球速低于设定值
			if ball.velMod() < whtDefParam.goalieBallSpeed then
				--球在禁区,向球跑
				if math.abs(y) < param.penaltyWidth/2 and x < -(param.pitchLength/2 - param.penaltyDepth) then
					return tempXY
				-- 球在禁区外
				else					
 					--寻找对方离球最近的机器人
					local enemyNum = 0
					local tempEnemy = 9000
					for i = 0, param.maxPlayer-1 do
						if enemy.valid(i) then
							local dist2 = enemy.pos(i):dist(tempXY)		
							if dist2 < tempEnemy then
								tempEnemy = dist2
								enemyNum = i
							end
						end
					end
					--机器人指向球门二边的弧度
					enemyP = enemy.pos(enemyNum)
					enemyDir = enemy.dir(enemyNum)
					tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-enemyP):dir()
					tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-enemyP):dir()
					--机器人的y值在分界点二边，得到的弧度会正负变化，所以要分开处理
					if math.abs(enemy.posY(enemyNum)) > param.goalWidth/2  then
						if enemyDir < tempDir1 + 0.1 and enemyDir> tempDir2 - 0.1 then
						    flag = 3
						end
					else 
						if enemyDir < tempDir1 + 0.1 and enemyDir > - math.pi  or enemyDir > tempDir2 - 0.1  then
						    flag = 3
						end					
					end							
				end 
			-- 有球速 
			else
				--球指向球门二边的弧度
				tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-tempXY):dir()
				tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-tempXY):dir()
				--球的y值在分界点二边，得到的弧度会正负变化，所以要分开处理
				if math.abs(y) > param.goalWidth/2  then
					if tempDir < tempDir1 + 0.1 and tempDir > tempDir2 - 0.1 then
					    flag = 2
					end
				else 
					if tempDir < tempDir1 + 0.1 and tempDir > - math.pi  or tempDir > tempDir2 - 0.1  then
					    flag = 2
					end					
				end			
			end
			local playerP = player.pos(runner)	--守门员位置	
			local movePoint --线段的另一点
			local seg   -- 线段
			--防守对方机器人弧度延长线上的垂直点
			if flag == 3 then
				movePoint = enemyP + Utils.Polar2Vector(1000,enemyDir)
				seg = CGeoSegment:new_local(enemyP, movePoint)
				return seg:projection(playerP)	
			--防守球移动弧度延长线上的垂直点
			elseif flag == 2 then
				movePoint = tempXY + Utils.Polar2Vector(1000,tempDir)
				seg = CGeoSegment:new_local(tempXY, movePoint)
				return seg:projection(playerP)	
			--移动到球与球门中点的连线上,离球门中点距离为param.goalWidth/2
			else
				local defP = CGeoPoint:new_local(-param.pitchLength/2,0) --球门中点
				local defP2BallDir =  (tempXY- defP):dir()
				local moveP = defP +  Utils.Polar2Vector(param.goalWidth/2,defP2BallDir)
				local returnX = moveP:x()
				local returnY = moveP:y()
				local minX =  -param.pitchLength/2 + param.playerRadius
				if returnX < minX then
					returnX = minX
				end
				return CGeoPoint:new_local(returnX,returnY)
			end			
		end 
	end 

	local idir =  function(runner)		
		local pDir = (ball.pos()- player.pos(runner)):dir() -- 对准球
		if  whtDefFunction.BallInOurPenalty() and ball.velMod() < whtDefParam.goalieBallSpeed  then
			return pDir
		else
			local ballDir = ball.velDir()
			local ballP = ball.pos()
			local ballPY = ball.posY()
			-- 计算球指向球门二边的弧度
			local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-ballP):dir()
			local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-ballP):dir()
			-- 分界点外， 对准来球方向
			if math.abs(ballPY)  > param.goalWidth/2 then
				if ballDir < tempDir1 and ballDir > tempDir2  then
					 -- 对准来球方向
					 if ballDir > 0 then
					 	pDir = ballDir - math.pi 
					 else
					 	pDir = ballDir + math.pi
					 end 
				end
			end
		end
		--分界点内，默认对准球
		return pDir 
	end	
	local ikick = function()
		--球在禁区时，且速度低于某个设定值后，启动挑射
		if  whtDefFunction.BallInOurPenalty() and ball.velMod() < whtDefParam.goalieBallSpeed  then
			return 2
		else
			return 0
		end 
	end
    function specifiedFlat()
			return 0
	end
    function specifiedChip()
		return 2500  --测试挑射力度
	end
	local f = flag.nothing
	local a = 6500-- 测试哪个加速度最快
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
end
















-- 1.2 后防 
-- 防守球门左区域中点\右区域中点\中心
-- 球消失时使用当前机器人的位置和弧度
-- 当球靠近防守机器人时,主动出机挑射
-- n 为1 左防守,为2 右防守 ,3为中防
--防过设计了二种方式，使用时注释掉一个，建议三机器人使用左右区域联防，只有二个机器人使用集中联防 
-- 					function backDef(role,n) : 三个机器人集中联防 	
--					function backDef(role,n) :三个机器人分左右区域联防,推荐使用

--1.3 协防			
-- 					robotDef(role,n)  参数n表示防守优先级,1为最大
-- 					离我方球门越近优先级越高




-- 	防守对方运球（旋转）： 
-- 1. 通过比较球的弧度是否在球门内，
-- 2. 再比较前后帧的弧度变化是否在设定范围内（旋转球弧度变化大，射门线变化小）


-- function luaGoalie()
-- 	local ipos = function()		
-- 		--保存初始球的状态
-- 		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
-- 		local tempDir = -math.pi -- 保存当前帧的球的弧度
-- 		local preDir = -math.pi  -- 保存前一帧的球的弧度
-- 		return function(runner)
-- 			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
-- 			if whtFunction.BallInField() then
-- 				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
-- 				tempDir = ball.velDir()
-- 			end 
-- 			-- 计算前后二帧球的弧度差值
-- 			local subDir
-- 			if tempDir * preDir > 0 then
-- 				subDir = math.abs(tempDir - preDir)
-- 			else
-- 				subDir = 2*math.pi - math.abs(tempDir - preDir)
-- 			end
-- 			--计算好差值后,用当前帧赋值给前一帧变量 
-- 			if whtFunction.BallInField() then
-- 				preDir = ball.velDir()
-- 			end 
-- 			-- 得到球的X，Y坐标值，为了判断是否在禁区内
-- 			local x = tempXY:x()
-- 			local y = tempXY:y()
-- 			-- 如果球在禁区内,且速度小于某个设定值,守门员出击把球踢出去
-- 			if math.abs(y) < param.penaltyWidth/2 and x < -(param.pitchLength/2 - param.penaltyDepth) 
-- 				and ball.velMod() < whtParam.goalieBallSpeed then
-- 				return tempXY
-- 			--否则, 防守
-- 			--判断球的移动弧度延长线在球门内且前后帧球弧度的偏差在设定值内,防守垂直点
-- 			--如不在,默认防守球与球门中点的连线
-- 			else 	
-- 				local flag = false --默认防守球与球门中点的连线
-- 				--球指向球门二边的弧度
-- 				local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-tempXY):dir()
-- 				local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-tempXY):dir()
-- 				--球的y值在分界点二边，得到的弧度会正负变化，所以要分开处理
-- 				if math.abs(y) > param.goalWidth/2  then
-- 					if tempDir < tempDir1 + 0.1 and tempDir > tempDir2 - 0.1 then
-- 					    if subDir < 0.12 then
-- 					    	flag = true
-- 					    end 
-- 					end
-- 				else 
-- 					if tempDir < tempDir1 + 0.1 and tempDir > - math.pi  or tempDir > tempDir2 - 0.1  then
-- 					    if subDir < 0.12 then
-- 					    	flag = true
-- 					    end 
-- 					end					
-- 				end
-- 				--防守垂直点
-- 				if flag then
-- 					local playerP = player.pos(runner)
-- 					local movePoint = tempXY + Utils.Polar2Vector(1000,tempDir)
-- 					local seg = CGeoSegment:new_local(tempXY, movePoint)
-- 					return seg:projection(playerP)	
-- 				--移动到球与球门中点的连线上,离球门中点距离为param.goalWidth/2
-- 				else
-- 					local defP = CGeoPoint:new_local(-param.pitchLength/2,0)
-- 					local defP2BallDir =  (tempXY- defP):dir()
-- 					local moveP = defP +  Utils.Polar2Vector(param.goalWidth/2,defP2BallDir)
-- 					local returnX = moveP:x()
-- 					local returnY = moveP:y()
-- 					local minX =  -param.pitchLength/2 + param.playerRadius
-- 					if returnX < minX then
-- 						returnX = minX
-- 					end
-- 					return CGeoPoint:new_local(returnX,returnY)
-- 				end
-- 			end
-- 		end 
-- 	end 
-- 	local idir =  function(runner)		
-- 		local pDir = (ball.pos()- player.pos(runner)):dir() -- 对准球
-- 		if  whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed  then
-- 			return pDir
-- 		else
-- 			local ballDir = ball.velDir()
-- 			local ballP = ball.pos()
-- 			local ballPY = ball.posY()
-- 			local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-ballP):dir()
-- 			local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-ballP):dir()
-- 			-- 分界点外， 对准来球方向
-- 			--分界点内，默认对准球
-- 			if math.abs(ballPY)  > param.goalWidth/2 then
-- 				if ballDir < tempDir1 and ballDir > tempDir2  then
-- 					 -- 对准来球方向
-- 					 if ballDir > 0 then
-- 					 	pDir = ballDir - math.pi 
-- 					 else
-- 					 	pDir = ballDir + math.pi
-- 					 end 
-- 				end
-- 			end
-- 		end
-- 		return pDir 
-- 	end	
-- 	local ikick = function()
-- 		--球在禁区时，且速度低于某个设定值后，启动挑射
-- 		if  whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed  then
-- 			return 2
-- 		else
-- 			return 0
-- 		end 
-- 	end
--     function specifiedFlat()
-- 			return 0
-- 	end
--     function specifiedChip()
-- 		return 2500
-- 	end
-- 	local f = flag.nothing
-- 	local a = 6500
-- 	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
-- 	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
-- end



function luaGoalie()
	local ipos = function()		
		--保存初始球的状态
		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempDir = -math.pi -- 保存当前帧的球的弧度
		local preDir = -math.pi  -- 保存前一帧的球的弧度
		return function(runner)
			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				tempDir = ball.velDir()
			end 
			-- 计算前后二帧球的弧度差值
			local subDir
			if tempDir * preDir > 0 then
				subDir = math.abs(tempDir - preDir)
			else
				subDir = 2*math.pi - math.abs(tempDir - preDir)
			end
			--计算好差值后,用当前帧赋值给前一帧变量 
			if whtCommonFunction.BallInField() then
				preDir = ball.velDir()
			end 
			-- 得到球的X，Y坐标值，为了判断是否在禁区内
			local x = tempXY:x()
			local y = tempXY:y()
			-- 如果球在禁区内,且速度小于某个设定值,守门员出击把球踢出去
			if math.abs(y) < param.penaltyWidth/2 and x < -(param.pitchLength/2 - param.penaltyDepth) 
				and ball.velMod() < whtDefParam.goalieBallSpeed then
				return tempXY
			--否则, 防守
			--判断球的移动弧度延长线在球门内且前后帧球弧度的偏差在设定值内,防守垂直点
			--如不在,默认防守球与球门中点的连线
			else 	
				local flag = false --默认防守球与球门中点的连线
				--球指向球门二边的弧度
				local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-tempXY):dir()
				local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-tempXY):dir()
				--球的y值在分界点二边，得到的弧度会正负变化，所以要分开处理
				if math.abs(y) > param.goalWidth/2  then
					if tempDir < tempDir1 + 0.1 and tempDir > tempDir2 - 0.1 then
					    if subDir < 0.12 then
					    	flag = true
					    end 
					end
				else 
					if tempDir < tempDir1 + 0.1 and tempDir > - math.pi  or tempDir > tempDir2 - 0.1  then
					    if subDir < 0.12 then
					    	flag = true
					    end 
					end					
				end
				--防守垂直点
				if flag then
					local playerP = player.pos(runner)
					local movePoint = tempXY + Utils.Polar2Vector(1000,tempDir)
					local seg = CGeoSegment:new_local(tempXY, movePoint)
					return seg:projection(playerP)	
				--移动到球与球门中点的连线上,离球门中点距离为param.goalWidth/2
				else
					local defP = CGeoPoint:new_local(-param.pitchLength/2,0)
					local defP2BallDir =  (tempXY- defP):dir()
					local moveP = defP +  Utils.Polar2Vector(param.goalWidth/2,defP2BallDir)
					local returnX = moveP:x()
					local returnY = moveP:y()
					local minX =  -param.pitchLength/2 + param.playerRadius
					if returnX < minX then
						returnX = minX
					end
					return CGeoPoint:new_local(returnX,returnY)
				end
			end
		end 
	end 
	local idir =  function(runner)		
		local pDir = (ball.pos()- player.pos(runner)):dir() -- 对准球
		if  whtDefFunction.BallInOurPenalty() and ball.velMod() < whtDefParam.goalieBallSpeed  then
			return pDir
		else
			local ballDir = ball.velDir()
			local ballP = ball.pos()
			local ballPY = ball.posY()
			local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-ballP):dir()
			local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-ballP):dir()
			-- 分界点外， 对准来球方向
			--分界点内，默认对准球
			if math.abs(ballPY)  > param.goalWidth/2 then
				if ballDir < tempDir1 and ballDir > tempDir2  then
					 -- 对准来球方向
					 if ballDir > 0 then
					 	pDir = ballDir - math.pi 
					 else
					 	pDir = ballDir + math.pi
					 end 
				end
			end
		end
		return pDir 
	end	
	local ikick = function()
		--球在禁区时，且速度低于某个设定值后，启动挑射
		if  whtDefFunction.BallInOurPenalty() and ball.velMod() < whtDefParam.goalieBallSpeed  then
			return 2
		else
			return 0
		end 
	end
    function specifiedFlat()
			return 0
	end
    function specifiedChip()
		return 2500
	end
	local f = flag.nothing
	local a = 6500
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
end
