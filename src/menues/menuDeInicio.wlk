import wollok.game.*
import sonidos.*
import teclado.*
import menues.menuDePreparacion.*
import eventos.*

object menuDeInicio
{
	var estado = 0
	
	method generar()
	{ 
		teclado.cambiarEstado(estadoMenuDeInicio)
		game.onTick(400, "Animacion_Menu", { self.avanzarAnimacion() })
		
		game.addVisualIn(self, game.origin()) 
		game.addVisualIn(titulo, game.origin())
	}
	
	method cerrar()
	{
		game.removeTickEvent("Animacion_Menu")
		game.allVisuals().forEach{ visual => game.removeVisual(visual) }
	}
	
	method continuar()
	{
		self.cerrar()
		sonido.reproducir("Cursor.wav")
		menuDePreparacion.generar()
	}
	
	method image() = "assets/Interfaz/MenuDeInicio/Menu_Animacion_" + estado + ".png"
	
	method avanzarAnimacion() 
	{
		estado++
		if(estado >= 7)
			estado = 0
	}
}

object titulo
{	
	method image() = "assets/Interfaz/MenuDeInicio/TituloQuaternionDefense.png" 
}