class X2Actor_EvacZoneTarget_EN extends X2Actor_EvacZoneTarget;

var protected string UnsafeMeshPath;
var private StaticMesh UnsafeMesh;

simulated event PostBeginPlay()
{
	local Object object;
	super.PostBeginPlay();

	`log("UnsafeMeshPath=" $ default.UnsafeMeshPath,,'EvacNow');	
	object = `CONTENT.RequestGameArchetype(default.UnsafeMeshPath);
	`log("object="$object,,'EvacNow');
	UnsafeMesh = StaticMesh(object);
	`log("UnsafeMesh="$UnsafeMesh,,'EvacNow');
}

simulated function ShowBadMesh()
{
	`log("ShowBadMesh()",,'EvacNow');

	if (StaticMeshComponent.StaticMesh != UnsafeMesh) {
		`log("ShowBadMesh(): StaticMeshComponent.StaticMesh != UnsafeMesh",,'EvacNow');
		StaticMeshComponent.SetStaticMesh(UnsafeMesh);
	}
}

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
		bOwnerNoSee=FALSE
		CastShadow=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		HiddenGame=FALSE
	End Object	

	bStatic=FALSE
	bWorldGeometry=FALSE
	bMovable=TRUE
	UnsafeMeshPath = "UI_3D_EvacNow.Evacuation.EvacLocation_Unsafe"
}
