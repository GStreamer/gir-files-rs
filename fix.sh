#!/bin/bash
set -x -e

# https://github.com/gtk-rs/gir-files/blob/master/reformat.sh
# `///` used as `//` not works in Windows in this case
for file in *.gir; do
    xmlstarlet ed -L \
        -d '//_:doc/@line' \
        -d '//_:doc/@filename' \
        -d '///_:source-position' \
        -d '//_:doc-version' \
        -d '//_:method-inline' \
        "$file"
done

# replace wayland structures to gpointers
xmlstarlet ed --inplace \
    --update '//*[@c:type="wl_display*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_registry*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_compositor*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_subcompositor*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_shell*"]/@c:type' \
    --value gpointer \
    GstGLWayland-1.0.gir
xmlstarlet ed --inplace \
    --update '//*[@c:type="wl_display*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_registry*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_compositor*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_subcompositor*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="wl_shell*"]/@c:type' \
    --value gpointer \
    GstVulkanWayland-1.0.gir

# Change X11's Display* and xcb_connection_t* pointers to gpointer
xmlstarlet ed --inplace \
    --insert '//_:type[@c:type="Display*"]' \
    --type attr --name 'name' --value 'gpointer' \
    --insert '//_:type[@c:type="xcb_connection_t*"]' \
    --type attr --name 'name' --value 'gpointer' \
    --update '//*[@c:type="Display*"]/@c:type' \
    --value gpointer \
    --update '//*[@c:type="xcb_connection_t*"]/@c:type' \
    --value gpointer \
    GstGLX11-1.0.gir
xmlstarlet ed --inplace \
    --insert '//_:type[@c:type="xcb_connection_t*"]' \
    --type attr --name 'name' --value 'gpointer' \
    --update '//*[@c:type="xcb_connection_t*"]/@c:type' \
    --value gpointer \
    GstVulkanXCB-1.0.gir

# Remove GstMemoryEGL and EGLImage
xmlstarlet ed --inplace \
    --delete '//_:record[@name="GLMemoryEGL"]' \
    --delete '//_:record[@name="GLMemoryEGLAllocator"]' \
    --delete '//_:record[@name="GLMemoryEGLAllocatorClass"]' \
    --delete '//_:record[@name="EGLImage"]' \
    --delete '//_:record[@name="GLDisplayEGLDeviceClass"]' \
    --delete '//_:class[@name="GLMemoryEGLAllocator"]' \
    --delete '//_:class[@name="GLDisplayEGLDevice"]' \
    --delete '//_:callback[@name="EGLImageDestroyNotify"]' \
    --delete '//_:constant[@name="GL_MEMORY_EGL_ALLOCATOR_NAME"]' \
    --delete '//_:function[starts-with(@name, "egl")]' \
    --delete '//_:function[starts-with(@name, "gl_memory_egl")]' \
    --delete '//_:function[@name="is_gl_memory_egl"]' \
    --delete '//_:function-macro[starts-with(@name, "egl")]' \
    --delete '//_:function-macro[starts-with(@name, "EGL")]' \
    --delete '//_:function-macro[starts-with(@name, "GL_MEMORY_EGL")]' \
    --delete '//_:function-macro[starts-with(@name, "IS_EGL_IMAGE")]' \
    --delete '//_:function-macro[starts-with(@name, "IS_GL_MEMORY_EGL")]' \
    GstGLEGL-1.0.gir

xmlstarlet ed --inplace \
    --delete '//_:method[@c:identifier="gst_gl_display_egl_from_gl_display"]' \
    --delete '//_:method[@c:identifier="egl_from_gl_display"]' \
    GstGLEGL-1.0.gir

# Remove all libcheck related API
xmlstarlet ed --inplace \
    --delete '//_:function[starts-with(@name, "check_")]' \
    --delete '//_:function[starts-with(@name, "buffer_straw_")]' \
    --delete '//_:callback[starts-with(@name, "Check")]' \
    --delete '//_:record[starts-with(@name, "Check")]' \
    GstCheck-1.0.gir
# Change GstVideoAncillary.data to a fixed-size 256 byte array
xmlstarlet ed --inplace \
    --delete '//_:record[@name="VideoAncillary"]/_:field[@name="data"]/_:array/@length' \
    --delete '//_:record[@name="VideoAncillary"]/_:field[@name="data"]/_:array/@fixed-size' \
    --insert '//_:record[@name="VideoAncillary"]/_:field[@name="data"]/_:array' \
    --type attr --name 'fixed-size' --value '256' \
     GstVideo-1.0.gir

xmlstarlet ed --inplace \
    --delete "//_:member[@c:identifier=\"GST_VIDEO_BUFFER_FLAG_ONEFIELD\"][2]" \
    --delete "//_:member[@c:identifier=\"GST_VIDEO_FRAME_FLAG_ONEFIELD\"][2]" \
    --delete "//_:member[@c:identifier=\"GST_NAVIGATION_MODIFIER_META_MASK\"][2]" \
    GstVideo-1.0.gir

xmlstarlet ed --inplace \
    --delete '//_:record[@name="ISO639LanguageDescriptor"]/_:field[@name="language"]/_:array/@c:type' \
    --insert '//_:record[@name="ISO639LanguageDescriptor"]/_:field[@name="language"]/_:array' \
    --type attr --name 'c:type' --value 'gchar' \
     GstMpegts-1.0.gir

xmlstarlet ed --inplace \
    --delete '//_:record[@name="MIKEYPayloadKeyData"]/_:field[@name="kv_data"]/_:array/@c:type' \
    --insert '//_:record[@name="MIKEYPayloadKeyData"]/_:field[@name="kv_data"]/_:array' \
    --type attr --name 'c:type' --value 'guint8' \
     GstSdp-1.0.gir

# Remove duplicated enums
xmlstarlet ed --inplace \
    --delete '//_:enumeration[@name="EditMode"]/_:member[starts-with(@name, "edit_")]' \
    --delete '//_:enumeration[@name="Edge"]/_:member[starts-with(@name, "edge_")]' \
    GES-1.0.gir

# replace native D3D12 types
xmlstarlet ed -L \
    -i '///_:type[not(@name) and @c:type="ID3D12Resource*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12Resource*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12CommandAllocator*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12CommandAllocator*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12Device*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12Device*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12CommandList*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12CommandList*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12CommandList**"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12CommandList**"]/@c:type' -v "gpointer*" \
    -i '///_:type[not(@name) and @c:type="ID3D12Fence*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12Fence*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12Fence**"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12Fence**"]/@c:type' -v "gpointer*" \
    -i '///_:type[not(@name) and @c:type="ID3D12CommandQueue*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12CommandQueue*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12GraphicsCommandList*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12GraphicsCommandList*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D12DescriptorHeap*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D12DescriptorHeap*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D11Texture2D*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D11Texture2D*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="ID3D11Device*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="ID3D11Device*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="IDXGIAdapter1*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="IDXGIAdapter1*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="IDXGIFactory2*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="IDXGIFactory2*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="HANDLE*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="HANDLE*"]/@c:type' -v "gpointer*" \
    -i '///_:type[not(@name) and @c:type="D3D12_RECT*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="D3D12_RECT*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="D3D12_PLACED_SUBRESOURCE_FOOTPRINT*"]' -t 'attr' -n 'name' -v "gpointer" \
    -u '//_:type[@c:type="D3D12_PLACED_SUBRESOURCE_FOOTPRINT*"]/@c:type' -v "gpointer" \
    -i '///_:type[not(@name) and @c:type="const LUID*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const LUID*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="D3D12_RESOURCE_FLAGS"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_RESOURCE_FLAGS"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_HEAP_FLAGS"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_HEAP_FLAGS"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_FENCE_FLAGS"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_FENCE_FLAGS"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_RESOURCE_STATES"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_RESOURCE_STATES"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_COMMAND_LIST_TYPE"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_COMMAND_LIST_TYPE"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_RESOURCE_DIMENSION"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_RESOURCE_DIMENSION"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="DXGI_FORMAT"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="DXGI_FORMAT"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_FORMAT_SUPPORT1"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_FORMAT_SUPPORT1"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="D3D12_FORMAT_SUPPORT2"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="D3D12_FORMAT_SUPPORT2"]/@c:type' -v "gint" \
    -i '///_:type[not(@name) and @c:type="const D3D12_RESOURCE_DESC*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_RESOURCE_DESC*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="const D3D12_DESCRIPTOR_HEAP_DESC*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_DESCRIPTOR_HEAP_DESC*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="const D3D12_CLEAR_VALUE*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_CLEAR_VALUE*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="const D3D12_HEAP_PROPERTIES*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_HEAP_PROPERTIES*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="const D3D12_COMMAND_QUEUE_DESC*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_COMMAND_QUEUE_DESC*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="const D3D12_BLEND_DESC*"]' -t 'attr' -n 'name' -v "gconstpointer" \
    -u '//_:type[@c:type="const D3D12_BLEND_DESC*"]/@c:type' -v "gconstpointer" \
    -i '///_:type[not(@name) and @c:type="HRESULT"]' -t 'attr' -n 'name' -v "gint" \
    -u '//_:type[@c:type="HRESULT"]/@c:type' -v "gint" \
    -d '//_:record[@name="D3D12Frame"]' \
    -d '//_:function[starts-with(@name, "d3d12_frame")]' \
    GstD3D12-1.0.gir

