-- Initialize peripherals
local monitor = peripheral.find("monitor")
local chest = peripheral.find("chest")

-- Variables for UI navigation
local selectedRow = 1
local maxRowsPerPage = monitor.getHeight() - 4
local currentPage = 1
local rowsPerPage = 0

-- Function to update the monitor display
local function updateMonitor()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Chest Monitoring System")

    local items = chest.list()
    rowsPerPage = 0

    for i = (currentPage - 1) * maxRowsPerPage + 1, #items do
        if rowsPerPage >= maxRowsPerPage then
            break
        end
        rowsPerPage = rowsPerPage + 1

        local yPos = i - (currentPage - 1) * maxRowsPerPage + 2
        local itemName = items[i]
        local itemCount = items[itemName]

        monitor.setCursorPos(2, yPos)
        monitor.write(itemName)
        monitor.setCursorPos(15, yPos)
        monitor.write(tostring(itemCount))
    end

    monitor.setCursorPos(1, monitor.getHeight())
    monitor.write("Use arrow keys to navigate, Enter to deposit, Shift+Enter to withdraw")
end

-- Function to deposit an item
local function depositItem()
    local items = chest.list()
    local itemName = items[selectedRow + (currentPage - 1) * maxRowsPerPage]
    
    if itemName then
        chest.pushItems("front", itemName)
    end
end

-- Function to withdraw an item
local function withdrawItem()
    local items = chest.list()
    local itemName = items[selectedRow + (currentPage - 1) * maxRowsPerPage]
    
    if itemName then
        chest.pullItems("front", itemName)
    end
end

-- Main loop
while true do
    updateMonitor()
    local event, param1, param2 = os.pullEventRaw()

    if event == "key" then
        if param1 == 203 and selectedRow > 1 then  -- Left arrow
            selectedRow = selectedRow - 1
        elseif param1 == 205 and selectedRow < rowsPerPage then  -- Right arrow
            selectedRow = selectedRow + 1
        elseif param1 == 200 and currentPage > 1 then  -- Up arrow
            currentPage = currentPage - 1
        elseif param1 == 208 and currentPage * maxRowsPerPage < #chest.list() then  -- Down arrow
            currentPage = currentPage + 1
        elseif param1 == 28 then  -- Enter key
            if param2 == 0 then  -- Regular Enter
                depositItem()
            elseif param2 == 1 then  -- Shift+Enter
                withdrawItem()
            end
        end
    end
end
