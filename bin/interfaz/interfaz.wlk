import wollok.game.*

import datosEnPartida.*
import barraDeHabilidades.*
import inventarioDeEquipos.*
import inventarioGeneral.*
import inventarioDeRecursos.*
import objetosEnJuego.fondos.*

import cursores.*
import contadores.*

import items.items.*
import items.equipos.*

object interfaz 
{
	const ancho = game.width()
	const alto = game.height()
	
	var property itemACombinar = new NingunItem()
	
	method crearCasillaInterfaz(x, y, imagen)
	{
		new FondoInterfaz(imagen).ubicar(x, y)
	}
	method crearCasillaMarcoInventario(x, y)
	{
		var casillaInventario = new FondoInterfaz("Interfaz_Marco")
		game.addVisualIn(casillaInventario, game.at(x, y))
	}
	
	method generar()
	{	
		// Genera barras horizontales
		(ancho-3).times
		{ 
			num =>			
			// Fondos primera y última fila
			self.crearCasillaInterfaz(num, alto-1, "Interfaz_Fondo")
			self.crearCasillaInterfaz(num, 0, "Interfaz_Fondo")
			
			// Bordes primera y última fila
			self.crearCasillaInterfaz(num, alto-1, "Interfaz_Horizontal")
			self.crearCasillaInterfaz(num, 0, "Interfaz_Horizontal")
		}
		
		// Genera barras verticales
		(alto-2).times
		{ 
			num =>			
			// Fondos primera y 2 últimas columnas
			self.crearCasillaInterfaz(0, num, "Interfaz_Fondo")
			self.crearCasillaInterfaz(ancho-1, num, "Interfaz_Fondo")
			self.crearCasillaInterfaz(ancho-2, num, "Interfaz_Fondo")
			
			// Bordes primera columna
			self.crearCasillaInterfaz(0, num, "Interfaz_Vertical")
		}
		
		// Genera otras casillas con sus fondos y bordes
		self.crearCasillaInterfaz(0, 0, "Interfaz_Fondo")
		self.crearCasillaInterfaz(0, 0, "Interfaz_Esquina_Inferior_Izquierda_Con_Punto")
		
		self.crearCasillaInterfaz(ancho-1, 0, "Interfaz_Fondo")
		self.crearCasillaInterfaz(ancho-1, 0, "Interfaz_Horizontal")
		self.crearCasillaInterfaz(ancho-1, 0, "Interfaz_Esquina_Inferior_Derecha")
		
		self.crearCasillaInterfaz(ancho-2, 0, "Interfaz_Fondo")
		self.crearCasillaInterfaz(ancho-2, 0, "Interfaz_Horizontal")
		
		self.crearCasillaInterfaz(0, alto-1, "Interfaz_Fondo")
		self.crearCasillaInterfaz(0, alto-1, "Interfaz_Esquina_Superior_Izquierda_Con_Punto")
		
		self.crearCasillaInterfaz(ancho-1, alto-1, "Interfaz_Fondo")
		self.crearCasillaInterfaz(ancho-1, alto-1, "Interfaz_Horizontal")
		self.crearCasillaInterfaz(ancho-1, alto-1, "Interfaz_Esquina_Superior_Derecha")
		
		self.crearCasillaInterfaz(ancho-2, alto-1, "Interfaz_Fondo")
		self.crearCasillaInterfaz(ancho-2, alto-1, "Interfaz_Horizontal")
		
		// Genera marcos y bordes habilidades
		6.times{ num => self.crearCasillaInterfaz(5+num, alto-1, "Interfaz_Marco") }
		self.crearCasillaInterfaz(6, game.height()-1, "Interfaz_Vertical_Izquierda")
		self.crearCasillaInterfaz(11, game.height()-1, "Interfaz_Vertical_Derecha")
		
		// Genera bordes y marcos equipos
		3.times
		{
			num =>					
			self.crearCasillaInterfaz(ancho-1, alto-num-1, "Interfaz_Vertical_Derecha")
			self.crearCasillaInterfaz(ancho-2, alto-num-1, "Interfaz_Vertical_Izquierda")
			self.crearCasillaMarcoInventario(ancho-1, alto-num-1)
			self.crearCasillaMarcoInventario(ancho-2, alto-num-1)	
		}
		
		// Genera bordes y marcos para inventario
		10.times
		{
			num =>
			self.crearCasillaInterfaz(ancho-1, alto-num-4, "Interfaz_Vertical_Derecha")
			self.crearCasillaInterfaz(ancho-2, alto-num-4, "Interfaz_Vertical_Izquierda")
			self.crearCasillaMarcoInventario(ancho-1, alto-num-4)
			self.crearCasillaMarcoInventario(ancho-2, alto-num-4)
		}		
		self.crearCasillaInterfaz(ancho-1, alto-5, "Interfaz_Horizontal_Arriba")
		self.crearCasillaInterfaz(ancho-2, alto-5, "Interfaz_Horizontal_Arriba")
		self.crearCasillaInterfaz(ancho-1, alto-14, "Interfaz_Horizontal_Abajo")
		self.crearCasillaInterfaz(ancho-2, alto-14, "Interfaz_Horizontal_Abajo")
		
		// Genera bordes y marcos para recursos
		2.times
		{
			num =>
			self.crearCasillaInterfaz(ancho-1, num, "Interfaz_Vertical_Derecha")
			self.crearCasillaInterfaz(ancho-2, num, "Interfaz_Vertical_Izquierda")
			self.crearCasillaMarcoInventario(ancho-1, num)
			self.crearCasillaMarcoInventario(ancho-2, num)
		}
		
		barraDeHabilidades.generar()
		inventarioDeEquipos.generar()
		inventarioGeneral.generar()
		inventarioDeRecursos.generar()
		
		textoDeNivel.ubicar()
		textoDeExperiencia.ubicar()
		
		// Agrega el cursors
		cursorDeInventario.agregar()
	}
	
	method terminarCrafteo()
	{
		if(game.hasVisual(cursorItemACombinar))
			game.removeVisual(cursorItemACombinar)
		itemACombinar = new NingunItem()
	}
}

class CasillaDeInventarioEnInterfaz
{
	method ubicarEn(position)
	{
		game.addVisualIn(self, position)
		game.addVisualIn(new TresDigitos_Unidad(self, noMostrarCero), position)
		game.addVisualIn(new TresDigitos_Decena(self, noMostrarCero), position)
		game.addVisualIn(new TresDigitos_Centena(self, noMostrarCero), position)
	}
	
	method numeroAMostrar() = self.itemEnCasilla().numeroAMostrar()
	method itemEnCasilla()
	method image() = self.itemEnCasilla().image()
}