while wait() do
    print("Diffrent player v2")
    if Legit == nil then
        Legit = false
    end
    local SkipMirroredMaps = {
        ["Retro Coast"] = true,
        ["Zemblanity"] = true,
        ["Northren Mill"] = true,
        ["Mysterium"] = true,
        ["Decaying Silo"] = true,
        ["Active Volcanic Mines"] = true,
        ["Snowy Stronghold"] = true
    }
    --[[if getgenv().whatthefuckisthisyoumayaskitisaverylongvariblename then
        for _,v in ipairs(getgenv().whatthefuckisthisyoumayaskitisaverylongvariblename) do
            SkipMirroredMaps[v] = true
        end
    end--]]
    local Mirrored = false
    local NewV = Vector3.new
    local NewC = CFrame.new
    local AngC = CFrame.fromEulerAnglesXYZ
    local LP = game.Players.LocalPlayer
    local CurrentCamera = workspace.CurrentCamera
    local function toggleSlide(newValue)
        if newValue == true then
            LP.Character.HumanoidRootPart.Size = Vector3.new(2, 1, 1)
            LP.Character.BoundingBox.Size = Vector3.new(2, 1, 1)
            LP.Character.Humanoid.HipHeight = -1.5
        else
            LP.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            LP.Character.BoundingBox.Size = Vector3.new(2, 2, 1)
            LP.Character.Humanoid.HipHeight = 0
        end
        LP.Character.Animate.Sliding:Fire(newValue)
    end
    
    local function doSlide(delay)
        toggleSlide(true)
        task.wait(delay)
        toggleSlide(false)
    end
    
    local Multi = workspace.Multiplayer
    local RS = game:GetService('RunService')
    
    -- IMPORTANT
    --local CLMAIN = getsenv(LP.PlayerScripts.CL_MAIN_GameScript)
    local CLMAIN = {
        newAlert = function(txt)
            local msg = Instance.new("Hint", workspace)
            msg.Text = txt
            game.Debris:AddItem(msg, 3)  -- Fixed to use 'msg' instead of 'txt'
        end
    }
    local Alert = CLMAIN.newAlert
    local oldalert
    oldalert = hookfunction(CLMAIN.newAlert, function(...)
        return oldalert(...)
    end)
    if not getrenv().alreadystarted then
        CLMAIN.newAlert("TAS Player Started.", Color3.fromRGB(255, 149, 5))
        getrenv().alreadystarted = true
    else
        CLMAIN.newAlert("TAS Player ready for next map.", Color3.new(0,1,.5))
    end
    
    local Animate = getsenv(LP.Character.Animate)
    local Map = Multi:WaitForChild('NewMap', 9e6)
    local mapName = game:GetService("HttpService"):UrlEncode(Map:WaitForChild('Settings'):GetAttribute("MapName"))
    print(mapName)
    local path = game:HttpGet("https://raw.githubusercontent.com/Swelllow/Testing/main/Flood-GUI-main/TAS%20FILES/"..mapName..".json") -- may be more lag spikey but should work with wave readfile("Flood-GUI/TAS FILES/" .. mapName .. ".json")
    if #path > 50 then
        print("TAS FILE IS REAL")
    else
        print("TAS FILE BROKEN")
    end
    local TAS = game:GetService("HttpService"):JSONDecode(path)
    print(#path)
    if not TAS then
        CLMAIN.newAlert("TAS file for "..mapName.." is not in workspace folder!", Color3.new(1,0,0))
        LP.Character.Humanoid.Health = 0
        LP.CharacterAdded:wait()
    else
    CLMAIN.newAlert("TAS Loaded!")
    repeat task.wait() until Map.Name == "Map"
    
    local HighlightPath = game:GetService("Workspace").Multiplayer.Map.Settings:GetAttribute("Highlight")
    
    if HighlightPath then
        CLMAIN.newAlert("Map cannot be mirrored.", Color3.fromRGB(255, 100, 0))
        Mirrored = false
    else
        if SkipMirroredMaps[mapName] then
            CLMAIN.newAlert('Map cannot be mirrored.', Color3.fromRGB(255, 100, 0))
        else
            if Map:WaitForChild('Settings'):FindFirstChild("_MirrorMap") then
                CLMAIN.newAlert('Map is not mirrored.', Color3.fromRGB(255, 149, 5))
                Mirrored = false
            else
                CLMAIN.newAlert('Map is mirrored, TAS will be played mirrored!', Color3.fromRGB(255, 149, 5))
                Mirrored = true
            end
        end
    end
    
    local Spawn = (function() -- new spawn finder by "tomato.txt" on discord
        local Spawn = nil
    
        local connections = {}
        for _,v in ipairs(Map:GetChildren()) do
            if v.Name == "Part" then
                table.insert(connections, v:GetPropertyChangedSignal("Rotation"):Connect(function()
                    for _,v in ipairs(connections) do
                        v:Disconnect()
                    end
                    Spawn = v
                end))
            end
        end
        repeat task.wait() until Spawn
        CLMAIN.newAlert("Spawn found!", Color3.fromRGB(0, 255, 0))
        return Spawn
    end)()
    
    game:GetService("ReplicatedStorage").Remote.StartClientMapTimer.OnClientEvent:Wait()
    local TimeStart = tick()
    CLMAIN.newAlert('TAS Running..', Color3.fromRGB(255, 149, 5))
    PlayAnim = Animate.playAnimation
    Animate.playAnimation = function()end
    
    for _, v in next, Map:GetDescendants() do
        if v.Name == 'ButtonIcon' then
            local buttonPart = v.Parent.Parent:FindFirstChildOfClass('Part')
            if buttonPart ~= nil then
                buttonPart.Size = Vector3.new(6,6,6)
            end
        end
    end
    
    --[[
    local ToggleSwim = function(val)
        LP.Character.Animate.ToggleSwim:Fire(val)
    end
    ]]
    local BoundingBox = LP.Character.BoundingBox
    BoundingBox.CanTouch = false
    
    local function toggleTouch(bool)
        BoundingBox.CanTouch = bool
    end
    
    function isRandomString(str) -- basicly detects if button 99% of the time just checks if all capital
        for i = 1, #str do
            local ltr = str:sub(i, i)
            if ltr:lower() == ltr then
                return false
            end     
        end
        return true
    end
    
    
    local function badCheck(Thing) --  NOT walljump or NOT AIRTANK or explodingbutton hitbox :check:
        local Parent = Thing.Parent
        if not Thing:FindFirstChild("_Wall") then
            if Parent and not (Thing.Name == "Part" and isRandomString(Parent.Name)) then
                if Parent.Name == "AirTank" then
                    return true
                end
                return true
            end
            return true
        end
        return false
    end
    local walljumpfix
    walljumpfix = LP.Character.HumanoidRootPart.Touched:Connect(function(Thing)
        if badCheck(Thing) then
            toggleTouch(true)
        elseif Thing.Name == "RopeStart" then
            toggleTouch(true)
        else
            print("Didn't Touch:", Thing:GetFullName())
        end
    end)
    
    local walljumpfix2
    walljumpfix2 = LP.Character.HumanoidRootPart.TouchEnded:Connect(function(Thing)
        if badCheck(Thing) then
            toggleTouch(false)
        elseif Thing.Name == "RopeStart" then
            toggleTouch(false)
        end
    end)
    
    local function activateAnimation(CurrentAnimation)
        if CurrentAnimation and CurrentAnimation[1] and CurrentAnimation[2] and LP.Character and LP.Character.Humanoid then
            PlayAnim(CurrentAnimation[1],CurrentAnimation[2], LP.Character.Humanoid)
            if CurrentAnimation[1] == "walk" then
                Animate.setAnimationSpeed(.76) 
            elseif CurrentAnimation[1] == "slide" then
                task.spawn(doSlide, 0.10)
            end
        end
    end
    
    local Offset = Spawn.Position - NewV(0, 1000, 0)
    local OldFrame = 3
    
    local Loop
    local Death
    
    Death = LP.Character.Humanoid.Changed:Connect(function(Change)
        if Change == "Health" and LP.Character.Humanoid.Health == 0 then
            Death:Disconnect()
            Loop:Disconnect()
            CLMAIN.newAlert('Player Died.', Color3.new(1, 0, 0))
        end
    end)
    
    local RootPart = LP.Character.HumanoidRootPart
    if Legit then
        RootPart.RootJoint.Enabled = false
    end
    
    Loop = RS.Heartbeat:Connect(function(DeltaTime)
        local NewFrame = #TAS
        local Divider = OldFrame + 60
        if Divider < #TAS then
            NewFrame = Divider
        end
        for i = OldFrame, NewFrame do
            local CurrentInfo = TAS[i]
            if (tick() - TimeStart) < CurrentInfo.time then
                break
            elseif i >= #TAS then
                CLMAIN.newAlert('TAS Run Finished!', Color3.new(0, 1, 0))
                CLMAIN.newAlert('TAS Player By Tomato & Moz', Color3.new(0, 1, 0))
                Death:Disconnect()
                Loop:Disconnect()
                Animate.playAnimation = PlayAnim
                if LP.Character and LP.Character.Humanoid then
                    Animate.playAnimation("idle", 0.1, LP.Character.Humanoid)
                end
                walljumpfix:Disconnect()
                walljumpfix2:Disconnect()
                toggleTouch(true)
                if Legit then
                    RootPart.RootJoint.Enabled = true
                end
            elseif (tick() - TimeStart) >= CurrentInfo.time then
                OldFrame = i
                local CCFrame = CurrentInfo.CCFrame
                local CCameraCFrame = CurrentInfo.CCameraCFrame
                if Mirrored == true then
                    RootPart.CFrame = NewC(CCFrame[1], CCFrame[2], -CCFrame[3]) * AngC(-3.1415927410125732, CCFrame[5], -3.1415927410125732) + Offset
                    --workspace.CurrentCamera.CFrame = NewC(-CCameraCFrame[1], -CCameraCFrame[2], -CCameraCFrame[3]) * AngC(3.1415927410125732, CCameraCFrame[5], 3.1415927410125732) + Offset
                elseif Mirrored == true and Legit then
                    
                else
                    RootPart.CFrame = NewC(CCFrame[1], CCFrame[2], CCFrame[3]) * AngC(CCFrame[4], CCFrame[5], CCFrame[6]) + Offset
                    CurrentCamera.CFrame = NewC(CCameraCFrame[1], CCameraCFrame[2], CCameraCFrame[3]) * AngC(CCameraCFrame[4], CCameraCFrame[5], CCameraCFrame[6]) + Offset
                end
                activateAnimation(CurrentInfo.AAnimation)
            end
        end
    end)
    end
    end
