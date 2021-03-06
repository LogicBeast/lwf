#
# Copyright (C) 2012 GREE, Inc.
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#

class WebkitCSSDomElementRenderer
  constructor:(@factory, @node) ->
    @appended = false
    @node.style.visibility = "hidden"
    @matrix = new Matrix(0, 0, 0, 0, 0, 0)
    @matrixForDom = new Matrix(0, 0, 0, 0, 0, 0)
    @matrixForRender = new Matrix(0, 0, 0, 0, 0, 0)
    @alpha = -1
    @zIndex = -1
    @visible = false

  destructor: ->
    @factory.stage.parentNode.removeChild(@node) if @appended
    return

  destruct: ->
    if @factory.resourceCache.constructor is WebkitCSSResourceCache
      @factory.destructRenderer(@)
    else
      @destructor()
    return

  update:(m, c) ->

  render:(m, c, renderingIndex, renderingCount, visible) ->
    if @visible is visible
      return if visible is false
    else
      @visible = visible
      if visible is false
        @node.style.visibility = "hidden"
        return
      else
        @node.style.visibility = "visible"

    matrixChanged = @matrix.setWithComparing(m)
    return if !matrixChanged and @appended and
      @alpha is c.multi.alpha and
      @zIndex is renderingIndex + renderingCount

    unless @appended
      @appended = true
      @node.style.position = "absolute"
      @node.style.webkitTransformOrigin = "0px 0px"
      @node.style.display = "block"
      @factory.stage.parentNode.appendChild(@node)

    @alpha = c.multi.alpha
    @zIndex = renderingIndex + renderingCount

    style = @node.style
    style.zIndex = @zIndex
    style.opacity = @alpha
    style.webkitTransform = "none"

    rs = @factory.stage.getBoundingClientRect()
    rn = @node.getBoundingClientRect()
    dpr = if @factory.resourceCache.constructor is WebkitCSSResourceCache \
      then 1 else window.devicePixelRatio
    m = @matrixForDom
    m.scaleX = 1 / dpr
    m.scaleY = 1 / dpr
    m.translateX = rs.left - rn.left
    m.translateY = rs.top - rn.top

    m = Utility.calcMatrix(@matrixForRender, @matrixForDom, @matrix)
    if @use3D
      style.webkitTransform = "matrix3d(" +
        "#{m.scaleX},#{m.skew1},0,0," +
        "#{m.skew0},#{m.scaleY},0,0," +
        "0,0,1,0," +
        "#{m.translateX},#{m.translateY},0,1)"
    else
      style.webkitTransform = "matrix(" +
        "#{m.scaleX},#{m.skew1},#{m.skew0},#{m.scaleY}," +
        "#{m.translateX},#{m.translateY})"
    return

