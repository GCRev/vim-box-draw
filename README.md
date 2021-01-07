# Real box drawing characters!

Use the following method call to draw a box: 

```
:box#Draw()
```

I have the command bound to 'BD'

``` 
vnoremap BD ^[:call box#Draw()<CR> 
```

...where '^[' is the ESCAPE literal C-v ESC

Box draw only works when there is a Visual(Block) selection present. It replaces the outermost
boundary of the current visual selection with box-drawing characters; __it does not surround the
selection with box-drawing characters.__ Make sure to leave spaces around the text you want to
box-draw around.

The plugin will automatically detect existing box-draw characters and attempt to intuitively draw
over them, allowing you to overlay and append boxes together as in the example below. You can also
draw single lines from one wall of an existing box to the other to divide them.
 
- For the best results :set virtualedit=all or :set ve=all

- To undo virtualedit, :set virtualedit= or :set ve=

```js
function test() {
  /*
   * ┌──────────────────────────────┐ 
   * │ This is a box! It's useless, ├──────────────┐ 
   * │ but at least it looks nice   │ Attached box │ 
   * └───────────┬──────────────────┼───┐          │ 
   *             │ Intersecting box └───┼──────────┘ 
   *             └──────────────────────┘ 
   */
  console.log('hello werld')
}
```
