# BrowserExtensionSharedExample

Basic example of using BrowserEngineKit extension APIs to start and perform an
operation in a child process, using a shared Framework between both the content
extension and the main application.

Unfortunately, currently when building this app will end up creating 2 copies of
the EngineCommon shared framework and all of its resources, one for the main
application and one for the WebContent extension. If the other extension types
(Rendering and Networking) were also present, they would also get a full copy of
the EngineCommon shared framework.

In an ideal world, the code in this shared framework would only be present in
one location in the final app bundle and would be shared between the main
process and all BrowserEngineKit extensions.
