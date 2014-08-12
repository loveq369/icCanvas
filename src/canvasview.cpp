#include <icCanvasManager.hpp>

#include <cmath>
#include <algorithm>
#include <iostream>

icCanvasManager::CanvasView::CanvasView() {
    this->renderer = new icCanvasManager::Renderer();
    this->fitter = new icCanvasManager::SplineFitter();

    this->x_center = 0;
    this->y_center = 0;
    this->zoom = 65535; //TODO: Replace with Drawing-specified zoom
};

icCanvasManager::CanvasView::~CanvasView() {};

void icCanvasManager::CanvasView::attach_drawing(icCanvasManager::RefPtr<icCanvasManager::Drawing> drawing) {
    this->drawing = drawing;
};

void icCanvasManager::CanvasView::request_tiles(cairo_rectangle_t* rect) {
    int highest_zoom = std::ceil(31 - log2(icCanvasManager::TileCache::TILE_SIZE * this->zoom));
    double request_size = (UINT32_MAX >> highest_zoom) + 1;
    auto rect_x_scroll = this->x_scroll + (rect->x * this->zoom);
    auto rect_y_scroll = this->y_scroll + (rect->y * this->zoom);
    auto base_x = rect_x_scroll - fmod(rect_x_scroll, request_size) + (request_size / 2);
    auto base_y = rect_y_scroll - fmod(rect_y_scroll, request_size) + (request_size / 2);
    auto x_tile_count = std::ceil((rect->width * this->zoom) / (float)request_size);
    auto y_tile_count = std::ceil((rect->height * this->zoom) / (float)request_size);
    auto renderscheduler = icCanvasManager::Application::get_instance().get_render_scheduler();

    for (int i = 0; i <= x_tile_count; i++) {
        for (int j = 0; j <= y_tile_count; j++) {
            renderscheduler->request_tile(this->drawing, base_x + ((int)request_size * i), base_y + ((int)request_size * j), highest_zoom, this->drawing->strokes_count());
        }
    }
};

void icCanvasManager::CanvasView::draw_tiles(cairo_t* ctxt, cairo_rectangle_t* rect) {
    float square_size = std::max(rect->width, rect->height);
    int lowest_zoom = std::floor(31 - log2(square_size * this->zoom));
    int highest_zoom = std::ceil(31 - log2(icCanvasManager::TileCache::TILE_SIZE * this->zoom));

    //Phase 1: Look up tiles from cache

    icCanvasManager::TileCache::TileCacheQuery qu1;
    qu1.query_size_gte(lowest_zoom);
    qu1.query_size_lt(highest_zoom+2);
    qu1.query_time_limit(1);
    auto tilecache = this->drawing->get_tilecache();
    auto tilelist = tilecache->execute(qu1);
    auto begin = tilelist.begin(), end = tilelist.end();

    //Phase 2: Copy/scale tiles onto view
    for (; begin != end; begin++) {
        auto &tile = tilecache->tile_at(*begin);

        cairo_save(ctxt);

        auto tile_size = UINT32_MAX >> tile.size;
        auto tile_wndsize = tile_size / this->zoom;
        auto scale_factor = (float)icCanvasManager::TileCache::TILE_SIZE / tile_wndsize;
        int txpos, typos; //yes I know, typos

        this->coordToWindowspace(tile.x - tile_size / 2, tile.y - tile_size / 2, &txpos, &typos);

        cairo_scale(ctxt, scale_factor, scale_factor);
        cairo_set_source_surface(ctxt, tile.image, (double)txpos, (double)typos);
        cairo_paint(ctxt);

        cairo_restore(ctxt);
    }
};

void icCanvasManager::CanvasView::draw(cairo_t *ctxt) {
    auto clear_ptn = cairo_pattern_create_rgb(1.0f, 1.0f, 1.0f);

    //Phase 0: Clear the surface
    cairo_save(ctxt);
    cairo_set_source(ctxt, clear_ptn);
    cairo_paint(ctxt);
    cairo_pattern_destroy(clear_ptn);

    cairo_rectangle_list_t* rectList = cairo_copy_clip_rectangle_list(ctxt);
    for (int i = 0; i < rectList->num_rectangles; i++) {
        this->request_tiles(&rectList->rectangles[i]);
    }

    for (int i = 0; i < rectList->num_rectangles; i++) {
        this->draw_tiles(ctxt, &rectList->rectangles[i]);
    }

    cairo_rectangle_list_destroy(rectList);
    cairo_restore(ctxt);
};

void icCanvasManager::CanvasView::set_size(double width, double height, double ui_scale) {
    this->width = width;
    this->height = height;
    this->ui_scale = ui_scale;

    this->x_size = this->width * this->zoom;
    this->y_size = this->height * this->zoom;
    this->x_scroll = this->x_center - (width * this->zoom / 2.0);
    this->y_scroll = this->y_center - (height * this->zoom / 2.0);
};

void icCanvasManager::CanvasView::set_size(double ui_scale) {
    this->width = UINT32_MAX / this->zoom;
    this->height = UINT32_MAX / this->zoom;
    this->ui_scale = ui_scale;

    this->x_size = this->width * this->zoom;
    this->y_size = this->height * this->zoom;
    this->x_scroll = this->x_center - (width * this->zoom / 2.0);
    this->y_scroll = this->y_center - (height * this->zoom / 2.0);
};

void icCanvasManager::CanvasView::get_size(double *out_width, double *out_height, double *out_ui_scale) {
    if (out_width) *out_width = this->width;
    if (out_height) *out_height = this->height;
    if (out_ui_scale) *out_ui_scale = this->ui_scale;
};

void icCanvasManager::CanvasView::set_scroll_center(int x, int y) {
    this->x_center = x;
    this->y_center = y;

    this->x_size = this->width * this->zoom;
    this->y_size = this->height * this->zoom;
    this->x_scroll = this->x_center - (width * this->zoom / 2.0);
    this->y_scroll = this->y_center - (height * this->zoom / 2.0);
};

void icCanvasManager::CanvasView::set_zoom(int vpixel_size) {
    this->zoom = vpixel_size;

    this->x_size = this->width * this->zoom;
    this->y_size = this->height * this->zoom;
    this->x_scroll = this->x_center - (width * this->zoom / 2.0);
    this->y_scroll = this->y_center - (height * this->zoom / 2.0);
};

void icCanvasManager::CanvasView::windowToCoordspace(const int32_t x, const int32_t y, int32_t* out_tx, int32_t* out_ty) {
    if (out_tx) *out_tx = (int)((float)x * this->zoom + this->x_scroll);
    if (out_ty) *out_ty = (int)((float)y * this->zoom + this->y_scroll);
};

void icCanvasManager::CanvasView::coordToWindowspace(const int32_t x, const int32_t y, int32_t* out_tx, int32_t* out_ty) {
    if (out_tx) *out_tx = (int)((float)(x - this->x_scroll) / this->zoom);
    if (out_ty) *out_ty = (int)((float)(y - this->y_scroll) / this->zoom);
};

void icCanvasManager::CanvasView::mouse_down(int x, int y, int deltaX, int deltaY) {
    this->built_stroke = new icCanvasManager::BrushStroke();
    this->fitter->begin_fitting(this->built_stroke, this->width * this->zoom);
};

void icCanvasManager::CanvasView::mouse_drag(int x, int y, int deltaX, int deltaY) {
    int cx, cy, cdx = deltaX * this->zoom, cdy = deltaY * this->zoom;

    this->windowToCoordspace(x, y, &cx, &cy);
    this->fitter->add_fit_point(cx, cy, icCanvasManager::BrushStroke::PRESSURE_MAX, 0, 0, cdx, cdy);
};

void icCanvasManager::CanvasView::mouse_up(int x, int y, int deltaX, int deltaY) {
    this->fitter->finish_fitting();
    this->drawing->append_stroke(this->built_stroke);
    this->built_stroke = NULL;
};
