function Window:AddMinimizeButton(Configs)
    local Button = MakeDrag(Create("ImageButton", ScreenGui, {
        Size = UDim2.fromOffset(35, 35),
        Position = UDim2.fromScale(0.15, 0.15),
        BackgroundTransparency = 1,
        AutoButtonColor = false
    }))
    local Stroke, Corner
    if Configs.Corner then
        Corner = Make("Corner", Button)
        SetProps(Corner, Configs.Corner)
    end
    if Configs.Stroke then
        Stroke = Make("Stroke", Button)
        SetProps(Stroke, Configs.Stroke)
    end
    SetProps(Button, Configs.Button)
    Button.Activated:Connect(Window.Minimize)
    return {
        Stroke = Stroke,
        Corner = Corner,
        Button = Button
    }
end