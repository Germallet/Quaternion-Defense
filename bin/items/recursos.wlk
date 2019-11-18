import items.*

class Recurso inherits ItemAcumulable
{
	override method agregarAInventario(){}
	override method interactuar() {}
	override method direccion() = super() + "Recursos/" + self.nombre()
}

object madera inherits Recurso (cantidad = 0)
{
	override method nombre() = "Madera"
}
object piedra inherits Recurso (cantidad = 0)
{
	override method nombre() = "Piedra"
}
object hierro inherits Recurso (cantidad = 0)
{
	override method nombre() = "Hierro"
}
object oro inherits Recurso (cantidad = 0)
{
	override method nombre() = "Oro"
}

class RecursoNecesario
{
	const property cantidad
	
	constructor(_cantidad)
	{
		cantidad = _cantidad
	}
	
	method esMismoItem(item)
}

class MaderaNecesaria inherits RecursoNecesario
{
	override method esMismoItem(_madera) = _madera == madera 
}

class PiedraNecesaria inherits RecursoNecesario
{
	override method esMismoItem(_piedra) = _piedra == piedra 
}

class OroNecesario inherits RecursoNecesario
{
	override method esMismoItem(_oro) = _oro == oro 
}

class HierroNecesario inherits RecursoNecesario
{
	override method esMismoItem(_hierro) = _hierro == hierro 
}