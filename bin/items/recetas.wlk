import equipos.*
import interfaz.inventarioGeneral.*
import objetosEnJuego.estructuras.*
import recursos.*
import items.materiales.*
import escenario.*
import items.consumibles.*

class Receta 
{
	const property ingredientes
	const property generadorDeProducto 
	
	method sePuedeProducirCon(_ingredientes) = ingredientes.all{ ingrediente => _ingredientes.any{ _ingrediente => ingrediente.esMismoItem(_ingrediente) and ingrediente.cantidad() <= _ingrediente.cantidad() } }
	
	method producir(_ingredientes)
	{
		ingredientes.forEach{ ingrediente => _ingredientes.forEach{ _ingrediente => if(ingrediente.esMismoItem(_ingrediente)) _ingrediente.quitar(ingrediente.cantidad()) } }
		inventarioGeneral.agregarItem(generadorDeProducto.apply())
	}
}

class RecetaDeEstructura inherits Receta
{
	override method producir(_ingredientes)
	{
		ingredientes.forEach{ ingrediente => _ingredientes.forEach{ _ingrediente => if(ingrediente.esMismoItem(_ingrediente)) _ingrediente.quitar(ingrediente.cantidad()) } }
		generadorDeProducto.apply().construirEn(escenario.sobrevivienteSeleccionado().posicionDeEnFrente())
	}
}



//object recetaEstructuraTest inherits RecetaDeEstructura(ingredientes = #{new Arco(), new MaderaNecesaria(10)}, producto = new EstructuraTest()) {}
object listaDeRecetas
{
	// Todas las recetas del juego
	const recetas = 
	#{
		//Armas
		new Receta(ingredientes = #{new Palo(10), new MaderaNecesaria(15)}, generadorDeProducto = { new EspadaDeEntrenamiento() }),
		new Receta(ingredientes = #{new EspadaDeEntrenamiento(), new PiedraNecesaria(25)}, generadorDeProducto = { new Katana() }),
		new Receta(ingredientes = #{new EspadaDeEntrenamiento(), new HierroNecesario(25)}, generadorDeProducto = { new EspadaCorta() }),
		new Receta(ingredientes = #{new Palo(10), new HierroNecesario(15)}, generadorDeProducto = { new EspadaRecta() }),
		new Receta(ingredientes = #{new EspadaRecta(), new HierroNecesario(25)}, generadorDeProducto = { new EspadaGrande() }),
		
		new Receta(ingredientes = #{new Palo(20), new Cuerda(5)}, generadorDeProducto = { new Arco() }),
		
		//Equipos De Mano
		new Receta(ingredientes = #{new MaderaNecesaria(30), new PiedraNecesaria(30)}, generadorDeProducto = { new EscudoRedondo() }),
		new Receta(ingredientes = #{new BrazaleteDeOro(), new Diamante(10)}, generadorDeProducto = { new AnilloLujoso() }),
		new Receta(ingredientes = #{new OroNecesario(30), new HierroNecesario(30)}, generadorDeProducto = { new BrazaleteDeOro() }),
		
		//Cascos
		new Receta(ingredientes = #{new OroNecesario(25), new Cuerda(3)}, generadorDeProducto = { new CollarDeOro() }),
		new Receta(ingredientes = #{new Garra(10), new Cuerda(3)}, generadorDeProducto = { new CollarSalvaje() }),
		new Receta(ingredientes = #{new Cuero(10), new Cuerda(3)}, generadorDeProducto = { new CascoDeCuero() }),
		new Receta(ingredientes = #{new Rubi(15), new CascoDeCuero()}, generadorDeProducto = { new CascoDePaladin() }),
		new Receta(ingredientes = #{new CollarSalvaje(), new CascoDeCuero()}, generadorDeProducto = { new CascoDeGladiador() }),
		
		//Pecheras
		new Receta(ingredientes = #{new Cuero(10), new HierbaVerde(10)}, generadorDeProducto = { new CamisaVerde() }),
		new Receta(ingredientes = #{new Cuero(10), new Rubi(10)}, generadorDeProducto = { new CamisaAzul() }),
		new Receta(ingredientes = #{new Cuero(10), new CamisaVerde()}, generadorDeProducto = { new ArmaduraLigeraDeCuero() }),
		new Receta(ingredientes = #{new CamisaVerde(), new HierroNecesario(20)}, generadorDeProducto = { new ArmaduraLigeraDeHierro() }),
		new Receta(ingredientes = #{new CamisaAzul(), new Rubi(15)}, generadorDeProducto = { new ArmaduraDePaladin() }),
		new Receta(ingredientes = #{new CamisaAzul(), new HierroNecesario(35)}, generadorDeProducto = { new ArmaduraPesada() }),
		new Receta(ingredientes = #{new Pluma(25), new Diamante(5)}, generadorDeProducto = { new AlasDeAngel() }),
		
		//Pantalones
		new Receta(ingredientes = #{new Calzoncillos(), new Pluma(10)}, generadorDeProducto = { new PantalonesCortos() }),
		new Receta(ingredientes = #{new Calzoncillos(), new Cuero(10)}, generadorDeProducto = { new PantalonesLargos() }),
		
		//Pantalones
		new Receta(ingredientes = #{new BotasViejas(), new Cuero(15)}, generadorDeProducto = { new PantalonesLargos() }),
		new Receta(ingredientes = #{new BotasViejas(), new HierroNecesario(25)}, generadorDeProducto = { new PantalonesLargos() }),
		
		//Estructuras
		new RecetaDeEstructura(ingredientes = #{new EscudoRedondo(), new MaderaNecesaria(50)}, generadorDeProducto = { new MuroDeMadera() } ),
		new RecetaDeEstructura(ingredientes = #{new EscudoRedondo(), new PiedraNecesaria(50)}, generadorDeProducto = { new MuroDePiedra() } ),
		new RecetaDeEstructura(ingredientes = #{new Arco(), new PiedraNecesaria(50)}, generadorDeProducto = { new TorreDePiedra() } )
	 }
	
	method combinar(ingredienteUno, ingredienteDos)
	{
		var ingredientes = #{ ingredienteUno, ingredienteDos }
		var recetaDeCombinacion = recetas.filter{ receta => receta.ingredientes().all{ ingrediente => ingrediente.esMismoItem(ingredienteUno) or ingrediente.esMismoItem(ingredienteDos) } }
		
		if(not recetaDeCombinacion.isEmpty() and recetaDeCombinacion.uniqueElement().sePuedeProducirCon(ingredientes))
		{
				recetaDeCombinacion.uniqueElement().producir(ingredientes)
		}
	}
}