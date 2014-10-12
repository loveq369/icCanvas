/* A WindowDock is a Dock implementation that is designed to place Dockables
 * around a central widget.
 */
class icCanvasGtk.WindowDock : Gtk.Box, icCanvasGtk.Dock {
    private Gtk.Box _hbox; //For vertical DockingPorts.
    private Gtk.Widget? _center;
    
    private int _vbox_center; //Position of Hbox within self.
    private int _hbox_center; //Position of Center within Hbox.
    
    private struct RowData {
        public Gtk.Widget parent; //Widget which contains entire row structure.
        public icCanvasGtk.DockingBox row; //Widget which manages placement of dockables.
    }
    
    private Gee.Map<icCanvasGtk.Dock.Edge, Gee.List<RowData?>> _rows;
    
    public WindowDock() {
        Object(orientation:Gtk.Orientation.VERTICAL, spacing:0);
        this._hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        this._center = null;
        
        this.pack_start(this._hbox, true, true, 0);
        
        this._vbox_center = 0;
        this._hbox_center = 0;
        this._rows = new Gee.HashMap<icCanvasGtk.Dock.Edge, Gee.List<RowData?>>();
        
        this._rows.@set(icCanvasGtk.Dock.Edge.LEFT, new Gee.LinkedList<RowData?>());
        this._rows.@set(icCanvasGtk.Dock.Edge.RIGHT, new Gee.LinkedList<RowData?>());
        this._rows.@set(icCanvasGtk.Dock.Edge.TOP, new Gee.LinkedList<RowData?>());
        this._rows.@set(icCanvasGtk.Dock.Edge.BOTTOM, new Gee.LinkedList<RowData?>());
    }
    
    private int get_best_edge_box(icCanvasGtk.Dockable dockwdgt, icCanvasGtk.Dock.Edge edge) {
        var rowlist = this._rows.@get(edge);
        var i = rowlist.list_iterator();
        
        while (i.has_next()) {
            i.next();
            var dat = i.@get();
            
            if (dat.row.is_dockable_compatible(dockwdgt)) {
                return i.index();
            }
        }
        
        return -1;
    }
    
    public void insert_new_row(icCanvasGtk.Dock.Edge edge, uint before_row) {
        icCanvasGtk.DockingBox new_row;
        Gtk.Box tgt = this;
        
        if (edge == Edge.LEFT || edge == Edge.RIGHT) {
            new_row = new icCanvasGtk.DockingBox(Gtk.Orientation.VERTICAL);
            tgt = this._hbox;
        } else {
            new_row = new icCanvasGtk.DockingBox(Gtk.Orientation.HORIZONTAL);
        }
        
        if (edge == Edge.BOTTOM || edge == Edge.RIGHT) {
            before_row = tgt.get_children().length() - before_row;
        }
        
        tgt.pack_start(new_row, false, false, 0);
        
        RowData? dat = RowData();
        dat.parent = new_row;
        dat.row = new_row;
        
        this._rows.@get(edge).insert((int)before_row, dat);
    }
    
    /* Add a dockable widget to a particular edge of the dock.
     */
    public void add_dockable(icCanvasGtk.Dockable dockwdgt, icCanvasGtk.Dock.Edge edge) {
        var recommended_offset = get_best_edge_box(dockwdgt, edge);
        this.add_dockable_positioned(dockwdgt, edge, recommended_offset, -1);
    }
    
    public void add_dockable_positioned(icCanvasGtk.Dockable dockwdgt, icCanvasGtk.Dock.Edge edge, uint offsetFromEdge, int pos) {
        if (offsetFromEdge == -1) {
            this.insert_new_row(edge, 0);
            offsetFromEdge = 0;
        }
        
        RowData? dat = this._rows.@get(edge).@get((int)offsetFromEdge);
        dat.row.add(dockwdgt as Gtk.Widget);
        dat.row.reorder_child(dockwdgt as Gtk.Widget, pos);
        this.added_dockable(dockwdgt, this, dat.row);
    }
    
    /* Set the center widget.
     */
    public Gtk.Widget center {
        get {
            return this._center;
        }
        set {
            if (this._center != null) {
                this._hbox.remove(this._center);
            }
            
            this._center = value;
            
            this._hbox.pack_end(this._center, true, true, 0);
            this._hbox.reorder_child(this._center, this._hbox_center);
        }
    }
    
    /* Iterate over the rows of the dock.
     */
    public void foreach_rows(icCanvasGtk.Dock.RowIteratee ifunc) {
        bool should_continue = true;
        var i = this._rows.map_iterator();
        
        while (i.has_next() && should_continue) {
            i.next();
            
            var edge = i.get_key();
            var j = i.get_value().list_iterator();
            
            while (j.has_next() && should_continue) {
                j.next();
                
                should_continue = ifunc(edge, j.index(), j.@get().row);
            }
        }
    }
}