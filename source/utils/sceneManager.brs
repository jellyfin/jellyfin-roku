'
' Create a SceneManager instance to help manage application groups
function InitSceneManager(scene as object) as object
    ' Create a node object so data is passed by reference and to avoid
    ' having to re-save associative array in global variable.
    groupStack = CreateObject("roSGNode", "GroupStack")
    obj = {
        groupStack: groupStack,
        pushGroup: sub(group) : m.groupStack.callFunc("push", group) : end sub,
        popGroup: sub() : m.groupStack.callFunc("pop") : end sub,
        peekGroup: function() : return m.groupStack.callFunc("peek") : end function
    }
    return obj
end function
