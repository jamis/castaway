plan do
  sprite('credits.png').
    size(production.resolution.width, nil).
    effect(:pan, vertical: true, from: 1, to: 10).
    exit(12)
end
