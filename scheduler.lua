
local schedulerFrame = CreateFrame("Frame");
local lastRun = GetTime();

spamTask = {};

SLASH_SPAM1 = "/spam"
SlashCmdList["SPAM"] = function(...)
    local msg = string.join(" ", arg);
    local spamChannels = {1,GetWorldChannelIndex()};
    Scheduler.removeTask(spamTask);
    spamTask = {
        runNow = true;
        interval = 90;
        runTimes = 100;
        callback = function()
            for i, channelIndex in spamChannels do 
                SendChatMessage(msg, "CHANNEL", nil, channelIndex);
            end
        end;
    };
    
    Scheduler.addTask(spamTask);
end;

SLASH_STOPSPAM1 = "/stopspam"
SlashCmdList["STOPSPAM"] = function()
    Scheduler.removeTask(spamTask);
end

function GetWorldChannelIndex()
    local channelsList = {GetChannelList()}
    for listIndex, listElement in channelsList do
        if string.upper(listElement) == "WORLD" then
            return tonumber(channelsList[listIndex-1])
        end
    end
    return nil;
end

exampleTask = {
    callback = function() print("example task") end;
    interval = 1; --seconds
    runNow = true;
    runTimes = 5;
};


Scheduler = {
    tasks = {};
};

Scheduler.onUpdate = function()
    for task in Scheduler.tasks do
        Scheduler.handleTask(task);
    end
end;

Scheduler.addTask = function(task) 
    assert(type(task.callback) == "function");
    assert(type(task.interval) == "number");
    task.runTimes = task.runTimes or 1;
    task.runNow = task.runNow or false;
    task.lastRun = task.lastRun or GetTime();
    Scheduler.tasks[task] = task;
    if task.runNow == true then
        Scheduler.runTask(task);
    end
end;

Scheduler.removeTask = function(task)
    Scheduler.tasks[task] = nil;
end;

Scheduler.handleTask = function(task)
    if task.runTimes <= 0 then
        Scheduler.removeTask(task);
        return;
    end
    local now = GetTime();
    if now - task.lastRun >= task.interval then
        Scheduler.runTask(task);
    end
end;

Scheduler.runTask = function(task)
    task.lastRun = GetTime();
    task.callback();
    task.runTimes = task.runTimes - 1;
end


function IsChinese(input_string) -- copy pasted from ChatGPT 3.5
    local i = 1
    local len = string.len(input_string)

    while i <= len do
        local byte1 = string.byte(input_string, i)

        if byte1 >= 192 and byte1 <= 253 then
            -- This byte indicates that it's a multi-byte UTF-8 character
            local byte2 = string.byte(input_string, i + 1)

            if byte1 >= 228 and byte1 <= 233 and
               byte2 >= 128 and byte2 <= 191 then
                return true  -- It's a Chinese character
            end

            -- Check for other ranges if needed

            i = i + 2  -- Move to the next character
        else
            -- This is a single-byte UTF-8 character
            i = i + 1  -- Move to the next character
        end
    end

    return false
end


schedulerFrame:SetScript("OnUpdate", Scheduler.onUpdate);
local whisperHandler = CreateFrame("FRAME");
whisperHandler:RegisterEvent("CHAT_MSG_WHISPER");

local function OnEvent(self, ...)
    if event == "CHAT_MSG_WHISPER" then
        local msg = arg1;
        local sender = arg2;
        if IsChinese(msg) then
            SendChatMessage("Sorry, I don't understand Chinese", "WHISPER", nil, sender);
        end
    end
end

whisperHandler:SetScript("OnEvent", OnEvent);