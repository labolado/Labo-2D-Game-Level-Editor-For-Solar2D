local kernel = {}

kernel.language        = "glsl"
kernel.category        = "filter"
kernel.name            = "tiling"
-- kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData =
{
    {
        name = "tilingX", -- The property name exposed to Lua
        index = 0, -- This corresponds to CoronaVertexUserData.x
        default = 1
    },
    {
        name = "tilingY", -- The property name exposed to Lua
        index = 1, -- This corresponds to CoronaVertexUserData.y
        default = 1
    },
    {
        name = "rotation", -- The property name exposed to Lua
        index = 2, -- This corresponds to CoronaVertexUserData.z
        default = 0
    },
    -- {
    --     name = "ratio", -- The property name exposed to Lua
    --     index = 3, -- This corresponds to CoronaVertexUserData.w
    --     default = 1
    -- }
}

kernel.fragment =
[[
P_COLOR vec4 FragmentKernel( P_UV vec2 uv ){
    uv *= CoronaVertexUserData.xy;
    //P_UV vec2 epsilon = vec2(0.0000001, 0.0000001);
    //uv = fract(max(uv - epsilon, vec2(0, 0)));
    uv = fract(uv);
    //if (uv.x <= 0.0) uv.x = 1.0;
    //if (uv.y <= 0.0) uv.y = 1.0;
    P_COLOR vec4 col = texture2D( CoronaSampler0, uv );

    return CoronaColorScale(col);
}
]]

return kernel
