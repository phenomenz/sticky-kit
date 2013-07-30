$ = @jQuery || @Zepto

win = $ window
$.fn.stick_in_parent = (parent_selector) ->
  sticky_class = "is_stuck"

  for elm in @
    do (elm = $ elm) ->
      parent = elm.parent parent_selector

      border_top = parseInt parent.css("border-top-width"), 10
      padding_top = parseInt parent.css("padding-top"), 10
      padding_bottom = parseInt parent.css("padding-bottom")

      parent_top = parent.offset().top + border_top + padding_top

      parent_height = parent.height()
      height = elm.outerHeight true
      return if height == parent_height

      # create a spacer
      float = elm.css "float"

      spacer = $("<div />").css({
        width: elm.outerWidth true
        height: height
        display: elm.css "display"
        float: float
      })

      fixed = false
      bottomed = false
      last_pos = undefined
      offset = 0

      win.on "scroll", (e) =>
        scroll = win.scrollTop()
        if last_pos?
          delta = scroll - last_pos
        last_pos = scroll

        if fixed
          will_bottom = scroll + height + offset > parent_height + parent_top

          # unbottom
          if bottomed && !will_bottom
            bottomed = false
            elm.css {
              position: "fixed"
              bottom: ""
              top: 0
            }

          # unfixing
          if scroll < parent_top
            fixed = false
            offset = 0

            if float == "left" || float == "right"
              elm.insertAfter spacer

            spacer.detach()
            elm.css({
              position: ""
              "margin-left": ""
              "margin-right": ""
            }).removeClass(sticky_class)

          # updated offset
          win_height = win.height()
          if height > win_height # bigger than viewport
            unless bottomed
              offset -= delta
              before = offset
              offset = Math.max win_height - height, offset
              offset = Math.min 0, offset

              elm.css {
                top: offset + "px"
              }

        else
          # fixing
          if scroll > parent_top
            fixed = true
            css = {
              position: "fixed"
              top: offset
            }

            elm.css(css).addClass(sticky_class).after(spacer)

            if float == "left" || float == "right"
              spacer.append elm

        # this is down here because we can fix and bottom in same step when
        # scrolling huge
        if fixed
          will_bottom ?= scroll + height + offset > parent_height + parent_top

          # bottomed
          if !bottomed && will_bottom
            # bottomed out
            bottomed = true
            if parent.css("position") == "static"
              parent.css {
                position: "relative"
              }

            elm.css {
              position: "absolute"
              bottom: padding_bottom
              top: ""
            }
  @

