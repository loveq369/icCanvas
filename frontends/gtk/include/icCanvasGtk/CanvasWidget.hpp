#ifndef __ICCANVASGTK__CANVASWIDGET_HPP__
#define __ICCANVASGTK__CANVASWIDGET_HPP__

#include <gtkmm/widget.h>
#include <icCanvasManager.hpp>

namespace icCanvasGtk {
    class CanvasWidget : public Gtk::Widget {
            icCanvasManager::Renderer r;
            icCanvasManager::Drawing *doc;
        public:
            CanvasWidget();
            virtual ~CanvasWidget();
            
            void set_drawing(icCanvasManager::Drawing *newDoc);
        protected:
            virtual bool on_draw(const Cairo::RefPtr<Cairo::Context>& cr);
    };
}

#endif