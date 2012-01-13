#
# == Styles
#
# Styles define various properties of styleable items in a CSS-like syntax.
#
# If no background color is given no color will be set. This will ensure a
# custom background pixmap won't be overwritten.
#
# === Link
#
# http://subforge.org/projects/subtle/wiki/Styles

# Style for all style elements
style :all do
  background  "#202020"
  border      "#303030", 0
  padding     0, 3
end

# Style for the views
style :views do

  # Style for the active views
  style :focus do
    foreground  "#fecf35"
  end

  # Style for urgent window titles and views
  style :urgent do
    foreground  "#ff9800"
  end

  # Style for occupied views (views with clients)
  style :occupied do
    foreground  "#b8b8b8"
  end

  # Style for unoccupied views (views without clients)
  style :unoccupied do
    foreground  "#757575"
  end
end

# Style for sublets
style :sublets do
  foreground  "#cccccc"
end

# Style for separator
style :separator do
  foreground  "#757575"
end

# Style for focus window title
style :title do
  foreground  "#fecf35"
end

# Style for active/inactive windows
style :clients do
  active      "#303030", 0
  inactive    "#202020", 0
  margin      0
  width       50
end

# Style for subtle
style :subtle do
  margin      0, 0, 0, 0
  panel       "#202020"
  background  "#3d3d3d"
  stipple     "#757575"
end

# vim:ts=2:bs=2:sw=2:et:fdm=marker
