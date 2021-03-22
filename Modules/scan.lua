local Scan = {}

function Scan:Draw(AMM, target, style)
  if ImGui.BeginTabItem("Scan") then

    AMM.Theme:DrawCrossHair()

    local tabConfig = {
      ['NPCPuppet'] = {
        currentTitle = "Current Appearance:",
        buttons = {
          {
            title = "Cycle Appearance",
            width = style.halfButtonWidth,
            action = "Cycle"
          },
          {
            title = "Save Appearance",
            width = style.halfButtonWidth,
            action = "Save"
          },
        },
      },
      ['vehicleCarBaseObject'] = {
        currentTitle = "Current Model:",
        buttons = {
          {
            title = "Cycle Model",
            width = style.halfButtonWidth,
            action = "Cycle"
          },
          {
            title = "Save Appearance",
            width = style.halfButtonWidth,
            action = "Save"
          },
        },
      }
    }

    AMM.settings = false

    if target ~= nil then
      -- Generic Objects Setup for Tab
      if tabConfig[target.type] == nil then
        tabConfig[target.type] = {
          currentTitle = "Current Appearance:",
          buttons = {}
        }
      end

      AMM.Theme:Spacing(3)

      ImGui.Text(target.name)

      -- Check if target is V
      if t.appearance ~= "None" then

        AMM.Theme:Separator()

        AMM.Theme:TextColored(tabConfig[target.type].currentTitle)
        ImGui.Text(target.appearance)

        ImGui.Spacing()

        -- Check if Save button should be drawn
        local drawSaveButton = AMM:ShouldDrawSaveButton(target)

        if tabConfig[target.type] ~= nil then
          for _, button in ipairs(tabConfig[target.type].buttons) do
            ImGui.SameLine()

            if drawSaveButton == false or target.id == "0x903E76AF, 43" then
              button.width = style.buttonWidth
            end

            if button.action == "Cycle" and target.id ~= "0x903E76AF, 43" then -- Extra Handling for Johnny
              AMM:DrawButton(button.title, button.width, style.buttonHeight, button.action, target)
            end

            if drawSaveButton and button.action == "Save" then
              AMM:DrawButton(button.title, button.width, style.buttonHeight, button.action, target)
            end
          end

          ImGui.Spacing()

          local savedApp = nil
          local query = f("SELECT app_name FROM saved_appearances WHERE entity_id = '%s'", target.id)
          for app in db:urows(query) do
            savedApp = app
          end

          if savedApp ~= nil then
            AMM.Theme:TextColored("Saved Appearance:")
            ImGui.Text(savedApp)
            AMM:DrawButton("Clear Saved Appearance", style.buttonWidth, style.buttonHeight, "Clear", target)
          end
        end

        AMM.Theme:Separator()
      end

      AMM.Theme:TextColored("Possible Actions:")

      ImGui.Spacing()

      if target.handle:IsVehicle() then
        if ImGui.SmallButton("  Unlock Vehicle  ") then
          AMM:UnlockVehicle(target.handle)
        end

        if ImGui.SmallButton("  Repair Vehicle  ") then
          local vehPS = target.handle:GetVehiclePS()
          local vehVC = target.handle:GetVehicleComponent()

          target.handle:DestructionResetGrid()
          target.handle:DestructionResetGlass()

          vehPS:RepairVehicle()
          vehVC:ForcePersistentStateChanged()
        end
      end

      if target.handle:IsNPC() then
        local spawnID = AMM:IsSpawnable(target)
        if spawnID ~= nil then
          local favoritesLabels = {"  Add to Spawnable Favorites  ", "  Remove from Spawnable Favorites  "}
          target.id = spawnID
          AMM:DrawFavoritesButton(favoritesLabels, target)
          ImGui.Spacing()
        end
      end

      if AMM.userSettings.experimental then
        if ImGui.SmallButton("  Despawn  ") then
          target.handle:Dispose()
        end
      end

      AMM.Theme:Separator()

      if target.options ~= nil then
        AMM.Theme:TextColored("List of Appearances:")
        ImGui.Spacing()

        x = 0
        for _, appearance in ipairs(target.options) do
          local len = ImGui.CalcTextSize(appearance)
          if len > x then x = len end
        end

        x = x + 50
        if x < ImGui.GetWindowContentRegionWidth() then
          x = ImGui.GetWindowContentRegionWidth()
        end

        resX, resY = GetDisplayResolution()
        y = #target.options * 40
        if y > resY - (resY / 2) then
          y = resY / 3
        end

        if ImGui.BeginChild("Scrolling", x, y) then
          for i, appearance in ipairs(target.options) do
            if (ImGui.Button(appearance)) then
              local custom = AMM:GetCustomAppearanceParams(appearance, target)

              if #custom > 0 then
                AMM:ChangeScanCustomAppearanceTo(target, custom)
              else
                AMM:ChangeScanAppearanceTo(target, appearance)
              end
            end
          end
        end
        ImGui.EndChild()
      end
    else
      ImGui.NewLine()

      ImGui.PushTextWrapPos()
      ImGui.TextColored(1, 0.16, 0.13, 0.75, "No Target! Look at NPC, Vehicle or Object to begin")
      ImGui.PopTextWrapPos()

      ImGui.NewLine()
    end

    ImGui.EndTabItem()
  end
end

return Scan
